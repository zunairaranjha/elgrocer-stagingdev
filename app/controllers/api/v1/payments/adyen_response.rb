module API
  module V1
    module Payments
      class AdyenResponse < Grape::API
        version 'v1', using: :path
        format :json
        formatter :json, ->(object, env) { object.to_json }

        resource :payments do

          desc 'Allows Adyen Webhook Notification'
          params do
          end

          post '/adyen_notification' do
            notification_item = params[:notificationItems][0][:NotificationRequestItem]
            owner = if notification_item[:merchantReference].start_with?('O')
                      Order.find_by(id: notification_item[:merchantReference].split('-').last)
                    elsif notification_item[:merchantReference].start_with?('S')
                      Shopper.find_by(id: notification_item[:merchantReference].split('-').last)
                    else
                      Retailer.find_by(id: 16)
                    end
            Analytic.add_activity("Adyen:#{notification_item[:eventCode]}:#{notification_item[:success]}", owner, params)
            response_handler(notification_item, owner)
            send_kafka_event(owner, "Adyen:#{notification_item[:eventCode]}:#{notification_item[:success]}", notification_item) if owner.instance_of?(Order)
            params
            status 200
            '[accepted]'
          end
        end

        helpers do

          def response_handler(res, owner)
            case res[:eventCode].to_s
            when 'AUTHORISATION'
              auth_handler(res, owner)
            when 'AUTHORISATION_ADJUSTMENT'
              adjust_auth_handler(res, owner)
            when 'CAPTURE', 'REFUND', 'CANCELLATION'
              create_log(res, owner)
            end
          end

          def auth_handler(params, owner)
            if owner.instance_of?(Order)
              order = owner

              OnlinePaymentLog.add_adyen_activity(order, params.stringify_keys)
              if params[:success].to_s.eql?('false') && order.merchant_reference.present?
                send_notification(order, params[:reason])
                return
              end
              return if params[:success].to_s.eql?('false')

              card = if params[:paymentMethod] =~ /applepay/
                       CreditCard.create_credit_card(params)
                     else
                       CreditCard.find_by(trans_ref: params[:merchantReference].split('-')[1])
                     end
              if order.status_id == -1
                order.status_id = 0
                OrderAllocation.where(order_id: order.id, is_active: true).update_all(is_active: false)
                OrderAllocationJob.perform_later(order)
              end
              card_atr = card.present? ? card.attributes : {}
              order.update(credit_card_id: card&.id, card_detail: card_atr.merge('auth_amount' => params[:amount][:value], 'ps' => 'adyen'), merchant_reference: params[:pspReference], updated_at: Time.now)
              PromotionCodeRealization.where(order_id: order.id).update_all(retailer_id: order.retailer_id)
              ShopperMailer.order_placement(order.id).deliver_later
              SmsNotificationJob.perform_later(order.shopper_phone_number.phony_normalized, I18n.t('sms.auth_amount', order_id: order.id, amount: params[:amount][:value].to_i / 100.0))
            elsif owner.instance_of?(Shopper)
              CreditCard.create_credit_card(params, owner.check_fraudster("#{params[:additionalData][:cardBin]}-#{params[:additionalData][:cardSummary]}")) rescue nil
            end
          end

          def adjust_auth_handler(params, owner)
            return unless owner.instance_of?(Order)

            order = owner
            OnlinePaymentLog.add_adyen_activity(order, params.stringify_keys)
            if params[:success].to_s.eql?('false') && [-1, 0, 8].include?(order.status_id)
              order.update(status_id: -1)
              send_notification(order, params[:reason])
              return
            end
            return if order.status_id.positive?

            card = CreditCard.find_by(trans_ref: params[:merchantReference].split('-')[1])
            card_atr = card.present? ? card.attributes : {}
            order.status_id = 0
            order.update(card_detail: card_atr.merge('auth_amount' => params[:amount][:value], 'ps' => 'adyen'), updated_at: Time.now)
          end

          def create_log(params, owner)
            return unless owner.instance_of?(Order)

            order = owner
            if params[:eventCode].to_s.eql?('REFUND') && params[:success].to_s.eql?('true')
              Slack::SlackNotification.new.send_partial_refund_notification(order, params)
              order.refunded_amount = order.refunded_amount.to_i + params[:amount][:value].to_i
              order.save
            elsif params[:eventCode].to_s.eql?('CANCELLATION') && params[:success].to_s.eql?('true')
              card_attr = order.card_detail || {}
              order.update(card_detail: card_attr.merge('is_void' => '1'))
            end
            OnlinePaymentLog.add_adyen_activity(order, params.stringify_keys)
          end

          def send_notification(order, reason)
            order.shopper.auth_payment_failed(order, reason)
          end

          def send_kafka_event(owner, event, response)
            Kafka::CloudKarafka.new.produce_finance_event_kafka_msg(owner, event, response)
          end

        end
      end
    end
  end
end
