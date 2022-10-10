class OnlinePaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  use ActionDispatch::RemoteIp

  def index; end

  def credit_card
    params[:client_ip] = request.headers['X-Forwarded-For'].to_s.split(',').first.to_s
    params[:app_version] = request.headers['App-Version']
    if request.headers['Referer'].present?
      params[:web_url] = Base64.encode64(request.headers['Referer'].to_s).gsub(/[\n=]/, '')
      params[:source] = 'WEB'
    else
      params[:web_url] = '1'
      params[:source] = (request.headers['App-Version'].to_s.length > 0 and request.headers['App-Version'].to_s.length <= 7) ? 'IOS' : 'ANDROID'
    end
    params[:locale] = (request.headers['Locale'].to_s.downcase.eql?('ar') ? 'ar' : 'en') unless params[:locale].present?
    I18n.locale = params[:locale]
    if params[:customer_email].present? and params[:merchant_reference].present?
      if Shopper.find_by(email: params[:customer_email])
        merchant_ref = params[:merchant_reference].split('-')
        merchant_ref[3] = (Time.now.to_f * 10).to_i
        params[:merchant_reference] = merchant_ref.join('-')
        @extra_params = params
      else
        redirection_manage('?message=error&error_type=1&error_code=4200&error_message=Shopper Not Found!', params[:web_url])
      end
    else
      redirection_manage('?message=error&error_type=1&error_code=4200&error_message=Missing Parameters', params[:web_url])
    end
  end

  def tokenization_response
    # @params = params
    failure_url = params[:merchant_extra2].split('-').length > 1 ? params[:merchant_extra2].split('-')[1] : params[:merchant_extra2].split('-')[0]
    I18n.locale = params[:language]
    shopper = Shopper.find_by(email: params[:merchant_extra1])
    return redirection_manage("?message=error&error_type=3&error_code=4200&error_message=#{I18n.t("errors.fraudster")}", failure_url) if shopper.check_fraudster(params[:card_number].to_s)
    if params[:status].to_i == 18
      card = CreditCard.new
      card.trans_ref = params[:token_name]
      card.last4 = params[:card_number].last(4)
      card.first6 = params[:card_number].first(6)
      card.expiry_year = params[:expiry_date].first(2).to_i
      card.expiry_month = params[:expiry_date].last(2).to_i
      card.shopper_id = shopper.id
      card.date_time_offset = params[:merchant_extra3]
      card.is_deleted = true
      card.save
      mer_ref = params[:merchant_reference].split('-')
      mer_ref.delete_at(2)
      response = Payfort::Payment.new(nil, nil, nil, params[:merchant_reference].split('-')[2].to_f / 100.0).authorize(params[:merchant_extra], ENV['BASE_URL'] + online_payments_authorization_response_path, params[:merchant_extra1], params[:token_name], mer_ref.join('-'), params[:merchant_extra2], nil, params[:language])
      if response['status'].eql?('20') || response['status'].eql?('02')
        redirect_to response['3ds_url']
      else
        redirection_manage("?message=error&error_type=2&error_code=4200&error_message=#{response['response_message']}", failure_url)
      end
    elsif params[:response_code].end_with?('016')
      redirection_manage("?message=error&error_type=1&error_code=4200&error_message=#{I18n.t("errors.card_number_invalid")}", failure_url)
    elsif params[:response_code].end_with?('100')
      redirection_manage("?message=error&error_type=1&error_code=4200&error_message=#{I18n.t("errors.expiry_date_invalid")}", failure_url)
    elsif params[:response_code].end_with?('012')
      redirection_manage("?message=error&error_type=1&error_code=4200&error_message=#{I18n.t("errors.card_expired")}", failure_url)
    elsif params[:response_code].end_with?('003')
      redirection_manage("?message=error&error_type=1&error_code=4200&error_message=#{I18n.t("errors.card_type_not_supported")}", failure_url)
    elsif params[:response_code].end_with?('006')
      redirection_manage("?message=error&error_type=1&error_code=4200&error_message=#{I18n.t("errors.technical_issue")}", failure_url)
    else
      redirection_manage("?message=error&error_type=1&error_code=4200&error_message=#{params[:response_message]}", failure_url)
    end
  end

  def authorization_response
    @params = params[:response_message]
    I18n.locale = params[:language]
    success_url = params[:merchant_extra].split('-')[0]
    failure_url = params[:merchant_extra].split('-').length > 1 ? params[:merchant_extra].split('-')[1] : params[:merchant_extra].split('-')[0]
    if params[:status].eql?('02')
      case params[:merchant_reference].split('-')[0].downcase
      when 'c'
        order = Order.find_by(id: params[:merchant_reference].split('-')[1].to_i)
        if order
          Analytic.add_activity('Authorization Response', order, params.stringify_keys)
          if order.merchant_reference.to_s.eql?(params[:merchant_reference])
            redirection_manage('?message=success', success_url)
          else
            card = CreditCard.find_by(trans_ref: params[:token_name])
            if card
              if order.status_id == -1
                card.update(card_type: params[:payment_option].eql?('VISA') ? '1' : '2', is_deleted: false, shopper_id: order.shopper_id)
                order.status_id = 0
              else
                PayfortJob.perform_later('void_authorization', order, nil, order.merchant_reference, order.card_detail['auth_amount'].to_i / 100.0)
              end
              order.update(credit_card_id: card.id, card_detail: card.attributes.merge(auth_amount: params[:amount]), merchant_reference: params[:merchant_reference], updated_at: Time.now)
              PromotionCodeRealization.where(order_id: order.id).update_all(retailer_id: order.retailer_id)
              ShopperMailer.order_placement(order.id).deliver_later
              SmsNotificationJob.perform_later(order.shopper_phone_number.phony_normalized, I18n.t('sms.auth_amount', order_id: order.id, amount: params[:amount].to_i / 100.0))
              redirection_manage('?message=success', success_url)
            else
              redirection_manage("?message=error&error_type=2&error_code=4200&error_message=#{I18n.t("errors.card_not_found")}", failure_url)
            end
          end
        else
          redirection_manage("?message=error&error_type=2&error_code=4200&error_message=#{I18n.t("errors.order_not_found")}", failure_url)
        end
      when 'm'
        card = CreditCard.find_by(trans_ref: params[:token_name])
        if card
          shopper = Shopper.find_by(email: params[:customer_email])
          if shopper
            card.update(card_type: params[:payment_option].eql?('VISA') ? '1' : '2', is_deleted: false, shopper_id: shopper.id)
            Payfort::Payment.new.void_auth(params[:merchant_reference], card)
            redirection_manage('?message=success', success_url)
          else
            redirection_manage('?message=error&error_type=2&error_code=4200&error_message=Shopper Not Found!', failure_url)
          end
        else
          redirection_manage("?message=error&error_type=2&error_code=4200&error_message=#{I18n.t("errors.card_not_found")}", failure_url)
        end
      end
    else
      redirection_manage("?message=error&error_type=2&error_code=4200&error_message=#{params[:response_message]}", failure_url)
    end
  end

  def require_cvv
    params[:client_ip] = request.headers['X-Forwarded-For'].to_s.split(',').first.to_s
    params[:app_version] = request.headers['App-Version']
    if request.headers['Referer'].present?
      params[:web_url] = Base64.encode64(request.headers['Referer'].to_s).gsub(/[\n=]/, '')
      params[:source] = 'WEB'
    else
      params[:web_url] = '1'
      params[:source] = (request.headers['App-Version'].to_s.length > 0 and request.headers['App-Version'].to_s.length <= 7) ? 'IOS' : 'ANDROID'
    end
    params[:locale] = (request.headers['Locale'].to_s.downcase.eql?('ar') ? 'ar' : 'en') unless params[:locale].present?
    I18n.locale = params[:locale]
    if (params[:token].present? or params[:card_id].present?) and params[:customer_email].present? and params[:merchant_reference].present?
      if Shopper.find_by(email: params[:customer_email])
        card = params[:token].present? ? CreditCard.find_by(trans_ref: params[:token]) : CreditCard.find_by(id: params[:card_id])
        if card
          params[:token] = card.trans_ref
          merchant_ref = params[:merchant_reference].split('-')
          merchant_ref[3] = (Time.now.to_f * 10).to_i
          params[:merchant_reference] = merchant_ref.join('-')
          @extra_params_cvv = params
        else
          redirection_manage("?message=error&error_type=2&error_code=4200&error_message=#{I18n.t("errors.card_not_found")}", params[:web_url])
        end
      else
        redirection_manage('?message=error&error_type=2&error_code=4200&error_message=Shopper Not Found!', params[:web_url])
      end
    else
      redirection_manage('?message=error&error_type=2&error_code=4200&error_message=Missing Parameters', params[:web_url])
    end
  end

  def authorization_request
    I18n.locale = params[:locale] || 'en'
    failure_url = params[:merchant_extra2].split('-').length > 1 ? params[:merchant_extra2].split('-')[1] : params[:merchant_extra2].split('-')[0]
    mer_ref = params[:merchant_reference].split('-')
    mer_ref.delete_at(2)
    res = Payfort::Payment.new(nil, nil, nil, params[:merchant_reference].split('-')[2].to_f / 100.0).authorize(params[:merchant_extra], ENV['BASE_URL'] + online_payments_authorization_response_path, params[:merchant_extra1], params[:token_name], mer_ref.join('-'), params[:merchant_extra2], params[:cvv], params[:locale] || 'en')
    if res['status'].eql?('20') || res['status'].eql?('02')
      redirect_to res['3ds_url']
    else
      redirection_manage("?message=error&error_type=2&error_code=4200&error_message=#{res['response_message']}", failure_url)
    end
  end

  def new_card
    params[:client_ip] = request.headers['X-Forwarded-For'].to_s.split(',').first.to_s
    params[:app_version] = request.headers['App-Version']
    params[:date_time_offset] = (request.headers['Datetimeoffset'] || 'Asia/Dubai').to_s if params[:date_time_offset].blank?
    if request.headers['Referer'].present?
      params[:web_url] = Base64.encode64(request.headers['Referer'].to_s).gsub(/[\n=]/, '')
      params[:source] = 'WEB'
    else
      params[:web_url] = '1'
      params[:source] = (request.headers['App-Version'].to_s.length > 0 and request.headers['App-Version'].to_s.length <= 7) ? 'IOS' : 'ANDROID'
    end
    params[:locale] = (request.headers['Locale'].to_s.downcase.eql?('ar') ? 'ar' : 'en') unless params[:locale].present?
    I18n.locale = params[:locale]
    if params[:email].present? and params[:merchant_reference].present?
      shopper = Shopper.find_by(email: params[:email])
      if shopper
        redirection_manage("?message=error&error_type=3&error_code=4200&error_message=#{I18n.t("errors.fraudster")}", params[:web_url]) if shopper.is_blocked
        merchant_ref = params[:merchant_reference].split('-')
        merchant_ref[3] = (Time.now.to_f * 10).to_i
        params[:merchant_reference] = merchant_ref.join('-')
        @extra_params = params
      else
        redirection_manage('?message=error&error_type=1&error_code=4200&error_message=Shopper Not Found!', params[:web_url])
      end
    else
      redirection_manage('?message=error&error_type=1&error_code=4200&error_message=Missing Parameters', params[:web_url])
    end
  end

  def authorization_call
    customer_ip = request.headers['X-Forwarded-For'].to_s.split(',').first.to_s
    if request.headers['Referer'].present?
      web_url = Base64.encode64(request.headers['Referer'].to_s).gsub(/[\n=]/, '')
      # source_app = "WEB"
    else
      web_url = '1'
      # source_app = (request.headers['App-Version'].to_s.length > 0 and request.headers['App-Version'].to_s.length <= 7) ? "IOS" : "ANDROID"
    end
    params[:locale] = (request.headers['Locale'].to_s.downcase.eql?('ar') ? 'ar' : 'en') unless params[:locale].present?
    I18n.locale = params[:locale]
    if params[:card_id].present? and params[:email].present? and params[:merchant_reference].present?
      shopper = Shopper.find_by(email: params[:email])
      if shopper
        card = CreditCard.find_by(id: params[:card_id])
        if card
          token_name = card.trans_ref
          merchant_ref = params[:merchant_reference].split('-')
          merchant_ref[3] = (Time.now.to_f * 10).to_i
          cvv = merchant_ref[4]
          order = Order.find(merchant_ref[1])
          amount = merchant_ref.delete_at(2)
          res = Payfort::Payment.new(nil, nil, nil, amount.to_f / 100.0).authorize(customer_ip, ENV['BASE_URL'] + online_payments_authorization_response_path, params[:email], token_name, merchant_ref.join('-'), web_url, cvv, params[:locale])
          if res['status'].eql?('20') || res['status'].eql?('02')
            Analytic.add_activity('Redirecting to 3ds_url', order, res)
            redirect_to res['3ds_url']
          else
            redirection_manage("?message=error&error_type=2&error_code=4200&error_message=#{res['response_message']}", web_url)
          end
        else
          redirection_manage("?message=error&error_type=2&error_code=4200&error_message=#{I18n.t("errors.card_not_found")}", web_url)
        end
      else
        redirection_manage('?message=error&error_type=2&error_code=4200&error_message=Shopper Not Found!', web_url)
      end
    else
      redirection_manage('?message=error&error_type=2&error_code=4200&error_message=Missing Parameters', web_url)
    end
  end

  def response_message
    render json: '' #params.except(:action,:controller).to_json
  end

  def redirection_manage(message, web_url = '')
    url = Base64.decode64(web_url)
    if url.empty?
      redirect_to ENV['BASE_URL'] + online_payments_response_message_path + message
    else
      redirect_to url + message
    end
  end
end

