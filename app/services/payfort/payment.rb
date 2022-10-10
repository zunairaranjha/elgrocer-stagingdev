# frozen_string_literal: true

module Payfort
  class Payment
    require 'digest'
    require 'net/http'
    require 'net/https'
    require 'openssl'

    def initialize(order = nil, shopper = nil, credit_card = nil, amount = 0)
      @order = order
      @shopper = shopper
      @credit_card = credit_card
      @amount = (amount * 100).round.to_s
      @merchant_identifier = ENV['MERCHANT_IDENTIFIER']
      @access_code = ENV['PAYFORT_ACCESS_CODE']
      @sha_request_phrase = ENV['SHA_REQUEST_PHRASE']
      @request_url = URI.parse(ENV['PAYFORT_URL'])
      @client = Net::HTTP.new(@request_url.host, @request_url.port)
      @client.use_ssl = true
      @client.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def purchase(merchant_reference = nil)
      body_params = request_params('PURCHASE')
      body_params['customer_email'] = @shopper.email
      body_params['merchant_reference'] = merchant_reference || @order.id.to_s
      body_params['token_name'] = @credit_card.trans_ref
      body_params['eci'] = 'RECURRING'
      body_params['signature'] = generate_signature(body_params)

      response = get_response(body_params)
      OnlinePaymentLog.add_activity(@order, response)
      if response['status'].eql?('14')
        Analytic.add_activity('Online Payment Success', @order, response)
        Kafka::CloudKarafka.new.produce_finance_event_kafka_msg(@order, 'Online Payment Success', response)
      else
        Analytic.add_activity('Online Payment Failed', @order, response)
        Kafka::CloudKarafka.new.produce_finance_event_kafka_msg(@order, 'Online Payment Failed', response)
      end
      response['response_message']
    end

    def authorize(customer_ip, return_url, cust_email, card_token, merchant_reference, merchant_extra, card_cvv = nil, language = 'en')
      body_params = request_params('AUTHORIZATION', merchant_reference)
      body_params['customer_email'] = cust_email
      body_params['token_name'] = card_token
      body_params['customer_ip'] = customer_ip
      body_params['card_security_code'] = card_cvv if card_cvv
      body_params['return_url'] = return_url
      body_params['merchant_extra'] = merchant_extra
      body_params['language'] = language
      body_params['signature'] = generate_signature(body_params)
      get_response(body_params)
      # response = get_response(body_params)
      # OnlinePaymentLog.add_activity(@order, response)
      # if response['status'].eql?('02')
      #   Analytic.add_activity("Payment Authorized", @order, response)
      # else
      #   Analytic.add_activity("Payment Authorization Failed", @order, response)
      # end
      # response['response_message']
    end

    def update_card(status)
      body_params = {
        'service_command' => 'UPDATE_TOKEN',
        'access_code' => @access_code,
        'merchant_identifier' => @merchant_identifier,
        'merchant_reference' => Time.now.to_i.to_s,
        'language' => 'en',
        'token_name' => @credit_card.trans_ref,
        'token_status' => status
      }
      body_params['signature'] = generate_signature(body_params)

      response = get_response(body_params)
      if response['status'].eql?('58')
        Analytic.add_activity('Card Updated', @credit_card, response)
      else
        Analytic.add_activity('Card Update Failed', @credit_card, response)
      end
      response['response_message']
    end

    def capture
      body_params = request_params('CAPTURE')
      body_params['signature'] = generate_signature(body_params)

      response = get_response(body_params)
      OnlinePaymentLog.add_activity(@order, response)
      if response['status'].eql?('04')
        Analytic.add_activity('Payment Captured', @order, response)
        Kafka::CloudKarafka.new.produce_finance_event_kafka_msg(@order, 'Payment Captured', response)
      else
        Analytic.add_activity('Payment Capture Failed', @order, response)
        Kafka::CloudKarafka.new.produce_finance_event_kafka_msg(@order, 'Payment Capture Failed', response)
      end
      response['response_message']
    end

    def void_authorization(merchant_reference, amount = nil)
      body_params = {
        'command' => 'VOID_AUTHORIZATION',
        'access_code' => @access_code,
        'merchant_identifier' => @merchant_identifier,
        'merchant_reference' => merchant_reference,
        'language' => 'en'
      }
      body_params['signature'] = generate_signature(body_params)

      response = get_response(body_params)
      OnlinePaymentLog.add_activity(@order, response)
      if response['status'].eql?('08')
        Analytic.add_activity('Authorization Voided', @order, response)
        Kafka::CloudKarafka.new.produce_finance_event_kafka_msg(@order, 'Authorization Voided', response)
        if response['status'].eql?('08')
          SmsNotificationJob.perform_later(
            @order.shopper_phone_number.phony_normalized,
            I18n.t('sms.void_payment', last_4_digit: @order.card_detail['last4'], amount: amount || @order.card_detail['auth_amount'].to_i / 100.0))
        end
      else
        Analytic.add_activity('Authorization Void Failed', @order, response)
        Kafka::CloudKarafka.new.produce_finance_event_kafka_msg(@order, 'Authorization Void Failed', response)
      end
      response['response_message']
    end

    def void_auth(merchant_reference, card)
      body_params = {
        'command' => 'VOID_AUTHORIZATION',
        'access_code' => @access_code,
        'merchant_identifier' => @merchant_identifier,
        'merchant_reference' => merchant_reference,
        'language' => 'en'
      }
      body_params['signature'] = generate_signature(body_params)

      response = get_response(body_params)
      if response['status'].eql?('08')
        Analytic.add_activity('Authorization Voided', card, response)
      else
        Analytic.add_activity('Authorization Void Failed', card, response)
      end
    end

    private

    def generate_signature(body_params)
      Digest::SHA2.hexdigest(@sha_request_phrase + body_params.sort_by { |key| key }.map { |key, value| "#{key}=#{value}" }.join + @sha_request_phrase)
    end

    def request_params(command, merchant_reference = nil)
      {
        'command' => command,
        'access_code' => @access_code,
        'merchant_identifier' => @merchant_identifier,
        'merchant_reference' => merchant_reference || @order.merchant_reference,
        'amount' => @amount,
        'currency' => 'AED',
        'language' => 'en'
      }
    end

    def get_response(body_params)
      request = Net::HTTP::Post.new(@request_url)
      request.add_field('Content-Type', 'application/json')
      request.body = body_params.to_json
      response = @client.request(request)
      response = JSON(response.body)
      response.except('merchant_identifier', 'access_code')
    end
  end
end
