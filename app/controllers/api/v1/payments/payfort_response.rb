module API
  module V1
    module Payments
      class PayfortResponse < Grape::API
        version 'v1', using: :path
        format :json

        resource :payments do
          desc 'Allows Payfort GET response'
          params do
          end

          get '/payfort_notification' do
            owner = Analytics.where("detail ilike '%#{params[:merchant_reference]}%'").first.owner rescue Retailer.find_by(id: 16)
            parameters = params.except('merchant_identifier', 'access_code', 'ip_address')
            Analytic.add_activity('Payfort Notification GET', owner, parameters)
            parameters
          end

          desc 'Allows Payfort POST response'
          params do
          end

          post '/payfort_notification' do
            owner = Analytics.where("detail ilike '%#{params[:merchant_reference]}%'").first.owner rescue Retailer.find_by(id: 16)
            parameters = params.except('merchant_identifier', 'access_code', 'ip_address')
            Analytic.add_activity('Payfort Notification POST', owner, parameters)
            parameters
          end

          desc 'Allows Payfort POST feedBack'
          params do
          end

          post '/payfort_feedback' do
            #       params.symbolize_keys!
            _params = params.symbolize_keys
            params = _params
            case params[:command].to_s
            when 'AUTHORIZATION'
              merchant_reference = params[:merchant_reference].split('-')
              if merchant_reference[0].downcase.eql?('c')
                order = Order.find_by(id: merchant_reference[1])
                if order
                  OnlinePaymentLog.add_activity(order, params.stringify_keys)
                  if params[:status].eql?('02') and !order.merchant_reference.to_s.eql?(params[:merchant_reference])
                    card = CreditCard.find_by(trans_ref: params[:token_name])
                    if order.status_id == -1
                      card.update(card_type: params[:payment_option].eql?('VISA') ? '1' : '2', is_deleted: false, shopper_id: order.shopper_id)
                      order.status_id = 0
                      OrderAllocation.where(order_id: order.id, is_active: true).update_all(is_active: false)
                      OrderAllocationJob.perform_later(order)
                    else
                      PayfortJob.perform_later('void_authorization', order, nil, order.merchant_reference, order.card_detail['auth_amount'].to_i / 100.0)
                    end
                    order.update(credit_card_id: card.id, card_detail: card.attributes.merge(auth_amount: params[:amount]), merchant_reference: params[:merchant_reference], updated_at: Time.now)
                    PromotionCodeRealization.where(order_id: order.id).update_all(retailer_id: order.retailer_id)
                    ShopperMailer.order_placement(order.id).deliver_later
                    SmsNotificationJob.perform_later(order.shopper_phone_number.phony_normalized, I18n.t('sms.auth_amount', order_id: order.id, amount: params[:amount].to_i / 100.0))
                  end
                  owner = order
                end
              else
                card = CreditCard.find_by(trans_ref: params[:token_name])
                owner = card if card
              end
            when 'VOID_AUTHORIZATION'
              merchant_reference = params[:merchant_reference].split('-')
              if merchant_reference[0].downcase.eql?('c')
                order = Order.find_by(id: merchant_reference[1])
                owner = order if order
              else
                card = CreditCard.find_by(trans_ref: params[:token_name])
                owner = card if card
              end
            end
            owner ||= Retailer.find(16)
            parameters = params.stringify_keys.except('merchant_identifier', 'access_code', 'ip_address')
            Analytic.add_activity('Payfort Feedback', owner, parameters)
            parameters
          end

          desc 'Allows Payfort GET redirection feedback'
          params do
          end

          get '/payfort_redirection' do
            owner = Analytics.where("detail ilike '%#{params[:merchant_reference]}%'").first.owner rescue Retailer.find_by(id: 16)
            parameters = params.except('merchant_identifier', 'access_code', 'ip_address')
            Analytic.add_activity('Payfort Redirection GET', owner, parameters)
            parameters
          end

          post '/payfort_redirection' do
            owner = Analytics.where("detail ilike '%#{params[:merchant_reference]}%'").first.owner rescue Retailer.find_by(id: 16)
            parameters = params.except('merchant_identifier', 'access_code', 'ip_address')
            Analytic.add_activity('Payfort Redirection POST', owner, parameters)
            parameters
          end
        end
      end
    end
  end
end