# frozen_string_literal: true

module API
  module V1
    module Payments
      class Capture < Grape::API
        include TokenAuthenticable
        include ResponseStatuses
        # helpers Concerns::CapturePaymentHelper
        version 'v1', using: :path
        format :json

        resources :payments do
          desc 'Allow Capture Payment'
          params do
            requires :order_id, type: Integer, desc: 'ID of the Order', documentation: { example: 78953245 }
            optional :amount, type: Float, desc: 'Amount to deduct', documentation: { example: 30 }
            optional :receipt_no, type: String, desc: 'Receipt number from retailer', documentation: { example: '7881927' }
            optional :en_route, type: Boolean, desc: 'Change order status to en_route or not', documentation: { example: true }
          end

          post '/capture' do
            order = Order.find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order

            return { message: 'ok' } if order.payment_type_id != 3

            if params[:amount] < 1.0
              { message: 'ok' }
            elsif order.card_detail['ps'] == 'adyen'
              req_params = adyen_params(order, params)
              if req_params['modificationAmount'][:value] > order.card_detail['auth_amount']
                response = Adyenps::Checkout.adjust_authorisation(req_params.merge({ 'adjustAuthorisationData' => order.orders_datum.detail['adjustAuthorisationData'] }))
                send_kafka_event('SyncAuthorisationAdjustment', req_params, response, order)
                if response.response['response'].eql?('Authorised')
                  order.card_detail['auth_amount'] = req_params['modificationAmount'][:value]
                  order.status_id = 11 if order.status_id == 7
                  # order.save
                  OrdersDatum.post_data(order.id, detail: { adjustAuthorisationData: response.response['additionalData']['adjustAuthorisationData'] })
                else
                  order.status_id = 7
                  error!(CustomErrors.instance.payment_issue(response.response['additionalData']['refusalReasonRaw']), 421)
                end
                order.final_amount = (req_params['modificationAmount'][:value] / 100.0).round(2)
                order.date_time_offset = request.headers['Datetimeoffset']
                order.save
              end
              response = Adyenps::Checkout.capture(req_params.except('adjustAuthorisationData'))
              send_kafka_event('Capture', req_params, response, order)
              if response.response['response'].eql?('[capture-received]')
                { message: 'ok' }
              else
                error!(CustomErrors.instance.payment_issue(response.response['additionalData']['refusalReasonRaw']), 421)
              end
            else
              shopper = order.shopper
              credit_card = order.credit_card
              error!(CustomErrors.instance.not_online_payment_no_card, 421) unless credit_card.present?
              amount = params[:amount].present? ? params[:amount] : order.final_amount
              # if amount < 1.0
              #   { message: 'ok' }
              # elsif order.orders_datum.detail['ps'].eql?('adyen')
              #   response = do_capture(order, amount)
              #   check_adyen_response(response, order, amount)
              # else
              response = ''
              auth_amount = order.card_detail['auth_amount'].to_i / 100.0
              if auth_amount >= amount && Analytic.where(owner: order, event_id: 21).count < 1 && Analytic.where(owner: order, event_id: 24).count < 1
                response = Payfort::Payment.new(order, shopper, credit_card, amount).capture
                response = do_recurring(response, order, shopper, credit_card, amount) unless response.downcase.eql?('success')
                check_response(response, order, amount)
              elsif Analytic.where(owner: order, event_id: 21).count < 1 && Analytic.where(owner: order, event_id: 24).count < 2
                extra_amount = amount - auth_amount
                if extra_amount < 5.0
                  extra_amount += 5.0
                  auth_amount -= 5.0
                end
                response = Payfort::Payment.new(order, shopper, credit_card, extra_amount).purchase
                if response.downcase.eql?('success')
                  response = Payfort::Payment.new(order, shopper, credit_card, auth_amount).capture if auth_amount.to_f > 0.0
                  response = do_recurring(response, order, shopper, credit_card, auth_amount) unless response.downcase.eql?('success')
                end
                check_response(response, order, amount)
              else
                error!(CustomErrors.instance.already_captured, 421)
              end
              # end
            end
          end
        end

        helpers do
          def check_response(response, order, amount)
            values = {
              final_amount: amount,
              receipt_no: params[:receipt_no],
              date_time_offset: request.headers['Datetimeoffset']
            }
            if response.downcase.eql?('success')
              values[:status_id] = 2 if params[:en_route]
              order.update(values.compact) if params[:amount].present? || params[:receipt_no].present? || params[:en_route].present?
              SmsNotificationJob.perform_later(order.shopper_phone_number.phony_normalized, I18n.t('sms.capture_payment', retailer_name: order.retailer_company_name, amount: amount, last_4_digit: order.card_detail['last4']))
              current_employee ? { message: 'ok' } : true
            else
              values[:status_id] = 7
              order.update(values.compact)
              error!(CustomErrors.instance.payment_failed(response), 421) if current_employee
              error!({ error_code: 423, error_message: "Online Payment Failed due to #{response}." }, 423)
            end
          end

          def do_recurring(response, order, shopper, credit_card, amount)
            RetailerMailer.payment_failed(order.id, response).deliver_later
            Payfort::Payment.new(order, shopper, credit_card, amount).purchase
          end

          def check_adyen_response(response, order, amount)
            values = {
              final_amount: amount,
              receipt_no: params[:receipt_no],
              date_time_offset: request.headers['Datetimeoffset']
            }
            if response.stringify_keys['status'].eql?('success')
              values[:status_id] = 2 if params[:en_route]
              order.update(values.compact) if params[:amount].present? || params[:receipt_no].present? || params[:en_route].present?
              SmsNotificationJob.perform_later(order.shopper_phone_number.phony_normalized, I18n.t('sms.capture_payment', retailer_name: order.retailer_company_name, amount: amount, last_4_digit: order.card_detail['last4']))
              current_employee ? { message: 'ok' } : true
            else
              values[:status_id] = 7
              order.update(values.compact)
              error!(CustomErrors.instance.payment_failed(response), 421) if current_employee
              error!({ error_code: 423, error_message: "Online Payment Failed due to #{response}." }, 423)
            end
          end

          def do_capture(order, amount)
            params = {
              'reference': order.id,
              'originalReference': order.merchant_reference,
              'modificationAmount': { currency: 'AED', value: amount }
            }
            response = Adyenps::Checkout.capture(params.stringify_keys)
            response
          end

          def adyen_params(order, params)
            req_params = {
              'modificationAmount' => { currency: 'AED', value: (params[:amount] * 100).to_i },
              'originalReference' => order.merchant_reference,
              'reference' => "O-#{order.id}"
            }
          end

          def send_kafka_event(activity, params, response, owner = nil)
            create_log(response, activity, owner)
            RequestResponseStreamJob.perform_later(topic: SystemConfiguration.get_key_value('orders_topic'), owner: (owner || current_shopper), event: "Adyen:#{activity}:#{SUCCESSFUL_HTTP_STATUS.include?(response.status) ? 'success' : 'failed'}", request: params, response: response.response)
          end

          def create_log(response, activity, owner = nil)
            Analytic.post_activity("Adyen:#{activity}:#{SUCCESSFUL_HTTP_STATUS.include?(response.status) ? 'success' : 'failed'}", owner || current_shopper, detail: response.to_json, date_time_offset: request.headers['Datetimeoffset'])
            response
          end

        end
      end
    end
  end
end
