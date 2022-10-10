# frozen_string_literal: true

module API
  module V1
    module Payments
      # module Adyen
      # Adyen checkout interface
      class AdyenCheckout < Grape::API
        # use ActionDispatch::RemoteIp
        include ResponseStatuses
        include TokenAuthenticable

        resources :payments do

          desc 'Get Payment Methods'
          params do
            optional :amount, type: Hash, desc: 'The currency and value of the new amount in minor units', documentation: { currency: 'AED', value: 1234 }
            optional :channel, type: String, desc: 'return URL/URI scheme', documentation: { example: true }
            optional :shopperReference, type: String, desc: 'shopper reference', documentation: { example: true }
            optional :countryCode, type: String, desc: 'The shopper country code', documentation: { example: 'US' }
            optional :shopperLocale, type: String, desc: 'The language that the payment methods will appear in', documentation: { example: 'en-US' }
          end

          # The call to /paymentMethods will be made as the checkout page is requested.
          # The response will be passed to the front end,
          # which will be used to configure the instance of `AdyenCheckout`
          post '/payment_methods' do
            response = Adyenps::Checkout.get_payment_methods(params)
            send_kafka_event('Payment Methods', params, response)
            create_log(response, 'Payment Methods')
          end

          desc 'Make payment request'
          params do
            requires :reference, type: String, desc: 'Order Number', documentation: { example: 78953245 }
            optional :amount, type: Hash
            optional :remote_ip, type: String, desc: 'remote ip address', documentation: { example: '7881927' }
            optional :paymentMethod, type: Hash, desc: 'The paymentComponentState.data.paymentMethod from your client app. This is from the state.data in the previous step', documentation: { example: 'true' }
            optional :returnUrl, type: String, desc: 'return URL/URI scheme', documentation: { example: true }
            optional :channel, type: String, desc: 'request channel', documentation: { example: true }
            optional :storePaymentMethod, type: Boolean, desc: 'Flag to store card', documentation: { example: true }
            optional :shopperReference, type: String, desc: 'shopperReference to store card with', documentation: { example: 123456 }
          end

          post '/initiate_payment' do
            # The call to /payments will be made as the shopper selects the pay button.
            # response = Adyenps::Checkout.make_payment(params["paymentMethod"], params["browserInfo"], request.remote_ip)
            error!(CustomErrors.instance.fraudster, 421) if current_shopper.is_blocked
            params[:reference] = params[:reference].split('-').insert(1, params[:paymentMethod][:storedPaymentMethodId]).join('-') if params[:paymentMethod][:storedPaymentMethodId]
            response = Adyenps::Checkout.make_payment(params)
            send_kafka_event('Initiate Payment', params, response)
            if params[:reference].start_with?('O') && SUCCESSFUL_HTTP_STATUS.include?(response.status) && ACCEPTED_STATUS.include?(response.response['resultCode'])
              Order.find_by(id: response.response['merchantReference'].split('-').last.to_i).update_column(:merchant_reference, response.response['pspReference'])
              OrdersDatum.post_data(response.response['merchantReference'].split('-').last.to_i, detail:
                { ps: 'adyen',
                  adjustAuthorisationData: response.response['additionalData']['adjustAuthorisationData']
                })
            end
            create_log(response, 'Initiate Payment')
            replace_if_error(response)
          end

          desc 'Submit payment details'
          params do
            requires :details, desc: 'ID of the Order', documentation: { example: 78953245 }
            optional :paymentData, desc: 'Amount to deduct', documentation: { example: 30 }
          end

          post 'submit_additional_details' do
            payload = {}
            payload['details'] = params['details']
            payload['paymentData'] = params['paymentData']

            response = Adyenps::Checkout.submit_details(payload)
            send_kafka_event('Submit Details', params, response)
            if SUCCESSFUL_HTTP_STATUS.include?(response.status) && response.response['merchantReference'].start_with?('O') && ACCEPTED_STATUS.include?(response.response['resultCode'])
              Order.find_by(id: response.response['merchantReference'].split('-').last.to_i).update_column(:merchant_reference, response.response['pspReference'])
              OrdersDatum.post_data(response.response['merchantReference'].split('-').last.to_i, detail:
                { ps: 'adyen',
                  adjustAuthorisationData: response.response['additionalData']['adjustAuthorisationData']
                })
            end
            create_log(response, 'Submit Details')
            replace_if_error(response)
          end

          desc 'Handle response'
          params do
            requires :redirectResult, desc: 'ID of the Order', documentation: { example: 78953245 }
          end

          post 'handle_shopper_redirect' do
            payload = {}
            payload['details'] = {
              'redirectResult' => params['redirectResult']
            }
            response = Adyenps::Checkout.submit_details(payload)
            send_kafka_event('Shopper Redirect', params, response)
            create_log(response, 'Shopper Redirect')
          end

          desc 'Make amount updates request'
          params do
            requires :modificationAmount, type: Hash, desc: 'The currency and value of the new amount in minor units', documentation: { currency: 'AED', value: 1234 }
            requires :originalReference, type: String, desc: 'The pspReference of the pre-authorisation request', documentation: { example: '78953245' }
            optional :reference, type: String, desc: 'Order Number', documentation: { example: '78953245' }
            optional :reason, type: String, desc: 'Reason for amount updates', documentation: { example: '7881927' }
          end

          post '/amount_updates' do
            response = Adyenps::Checkout.amount_updates(params)
            send_kafka_event('Amount Updates', params, response)
            create_log(response, 'Amount Updates')
          end

          desc 'Make payment session request'
          params do
            requires :amount, type: Hash
            requires :returnUrl, type: String, desc: 'return URL/URI scheme', documentation: { example: 'http://elgrocer.com' }
            requires :reference, type: String, desc: 'Order Number', documentation: { example: '78953245' }
            optional :expiresAt, type: String, desc: 'The session expiry date in ISO8601 format', documentation: { example: '2021-12-21T12:25:28Z' }
            optional :countryCode, type: String, desc: 'The shopper country code', documentation: { example: 'US' }
            optional :shopperLocale, type: String, desc: 'The language that the payment methods will appear in', documentation: { example: 'en-US' }
            optional :shopperEmail, type: String, desc: 'The shopper email address', documentation: { example: 'tariq@elgrocer.com' }
            # optional :applicationInfo, type: Hash, desc: 'For building an Adyen solution for multiple merchants and better support', documentation: { example: 123456 }
          end

          post '/payment_session' do
            response = Adyenps::Checkout.payment_session(params)
            send_kafka_event('Payment Session', params, response)
            create_log(response, 'Payment Session')
          end

          desc 'Make payment capture request'
          params do
            requires :modificationAmount, type: Hash, desc: 'The currency and value of the new amount in minor units', documentation: { currency: 'AED', value: 1234 }
            optional :originalReference, type: String, desc: 'The pspReference of the pre-authorisation request', documentation: { example: '78953245' }
            requires :reference, type: String, desc: 'Order Number', documentation: { example: '78953245' }
            optional :reason, type: String, desc: 'Reason for', documentation: { example: '7881927' }
          end

          post '/adyen_capture' do
            error!(CustomErrors.instance.invalid_reference_number, 421) unless params[:reference].start_with?('O')
            order = Order.find_by(id: params[:reference].split('-').last)
            error!(CustomErrors.instance.order_not_found, 421) unless order
            params[:originalReference] ||= order.merchant_reference
            if params[:modificationAmount][:value] > order.card_detail['auth_amount']
              response = Adyenps::Checkout.adjust_authorisation(params.merge({ 'adjustAuthorisationData' => order.orders_datum.detail['adjustAuthorisationData'] }))
              send_kafka_event('SyncAuthorisationAdjustment', params, response, order)
              create_log(response, 'SyncAuthorisationAdjustment', order)
              if response.response['response'].eql?('Authorised')
                order.card_detail['auth_amount'] = params[:modificationAmount][:value]
                order.status_id = 11 if order.status_id == 7
                # order.save
                OrdersDatum.post_data(order.id, detail: { adjustAuthorisationData: response.response['additionalData']['adjustAuthorisationData'] })
              else
                order.status_id = 7
                error!(CustomErrors.instance.payment_issue(response.response['additionalData']['refusalReasonRaw']), 421)
              end
              order.final_amount = (params[:modificationAmount][:value] / 100.0).round(2)
              order.date_time_offset = request.headers['Datetimeoffset']
              order.save
            end
            response = Adyenps::Checkout.capture(params.except('adjustAuthorisationData'))
            send_kafka_event('Capture', params, response, order)
            create_log(response, 'Capture', order)
            if response.response['response'].eql?('[capture-received]')
              { message: 'ok' }
            else
              error!(CustomErrors.instance.payment_issue(response.response['additionalData']['refusalReasonRaw']), 421)
            end
          end

          desc 'Make payment cancel request'
          params do
            # optional :modificationAmount, type: Hash, desc: 'The currency and value of the new amount in minor units', documentation: { currency: 'AED', value: 1234 }
            requires :originalReference, type: String, desc: 'The pspReference of the pre-authorisation request', documentation: { example: '78953245' }
            optional :reference, type: String, desc: 'Order Number', documentation: { example: '78953245' }
            optional :reason, type: String, desc: 'Reason for', documentation: { example: '7881927' }
          end

          post '/cancel' do
            response = Adyenps::Checkout.cancel(params)
            send_kafka_event('Cancel', params, response)
            create_log(response, 'Cancel')
          end

          desc 'Make payment refund request'
          params do
            optional :modificationAmount, type: Hash, desc: 'The currency and value of the new amount in minor units', documentation: { currency: 'AED', value: 1234 }
            requires :originalReference, type: String, desc: 'The pspReference of the pre-authorisation request', documentation: { example: '78953245' }
            optional :reference, type: String, desc: 'Order Number', documentation: { example: '78953245' }
            optional :reason, type: String, desc: 'Reason for', documentation: { example: '7881927' }
          end

          post '/refund' do
            response = Adyenps::Checkout.refund(params)
            create_log(response, 'Refund')
          end

          desc 'Make payment cancel_or_refund request'
          params do
            # optional :modificationAmount, type: Hash, desc: 'The currency and value of the new amount in minor units', documentation: { currency: 'AED', value: 1234 }
            requires :originalReference, type: String, desc: 'The pspReference of the pre-authorisation request', documentation: { example: '78953245' }
            optional :reference, type: String, desc: 'Order Number', documentation: { example: '78953245' }
            optional :reason, type: String, desc: 'Reason for', documentation: { example: '7881927' }
          end

          post '/cancel_or_refund' do
            response = Adyenps::Checkout.cancel_or_refund(params)
            create_log(response, 'Cancel or Refund')
          end

          desc 'Disables stored payment details to stop charging a shopper with this particular recurring detail ID'
          params do
            requires :shopperReference, type: String, desc: 'Unique Shopper Id', documentation: { example: '1234567' }
            optional :recurringDetailReference, type: String, desc: 'The ID that uniquely identifies the recurring detail reference', documentation: { example: '1234567898765432' }
            optional :cancel_orders, type: Boolean, desc: 'Cancel orders or not', documentation: { example: false }
          end

          post '/disable' do
            error!(CustomErrors.instance.not_allowed, 421) unless current_shopper
            card = CreditCard.find_by(trans_ref: params[:recurringDetailReference], shopper_id: current_shopper.id)
            error!(CustomErrors.instance.card_not_found, 421) unless card
            orders = Order.where(shopper_id: current_shopper.id, credit_card_id: card&.id, status_id: [0, 1, 6])
            error!(CustomErrors.instance.card_delete_cancel_order, 421) if orders.length.positive? && params[:cancel_orders].blank?
            response = Adyenps::Checkout.disable_payment(params)
            if params[:cancel_orders] && SUCCESSFUL_HTTP_STATUS.include?(response.status)
              orders.each { |order| order.update_attributes(status_id: 4, canceled_at: Time.now, user_canceled_type: 4, updated_at: Time.now) }
            end
            create_log(response, 'Disable Payment')
          end

        end

        helpers do
          def create_log(response, activity, owner = nil)
            Analytic.post_activity("Adyen:#{activity}:#{SUCCESSFUL_HTTP_STATUS.include?(response.status) ? 'success' : 'failed'}", owner || current_shopper, detail: response.to_json, date_time_offset: request.headers['Datetimeoffset'])
            response
          end

          def replace_if_error(response)
            return response unless SUCCESSFUL_HTTP_STATUS.include?(response.status) && ERROR_STATUS.include?(response.response['resultCode'])

            response.response['refusalReason'] = I18n.t("refusal_reasons.refusalReason_#{response.response['refusalReasonCode']}")
            response
          end

          def send_kafka_event(activity, params, response, owner = nil)
            RequestResponseStreamJob.perform_later(topic: SystemConfiguration.get_key_value('orders_topic'), owner: (owner || current_shopper), event: "Adyen:#{activity}:#{SUCCESSFUL_HTTP_STATUS.include?(response.status) ? 'success' : 'failed'}", request: params, response: response.response)
          end
        end
      end

      # end
    end
  end
end
