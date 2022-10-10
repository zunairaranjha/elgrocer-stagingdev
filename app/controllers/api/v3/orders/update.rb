module API
  module V3
    module Orders
      class Update < Grape::API
        include TokenAuthenticable
        helpers Concerns::OrderHelper
        version 'v3', using: :path
        format :json
        resources :orders do
          desc 'Allows update of an order'
          params do
            requires :order_id, type: Integer, desc: 'Order Id to Update', documentation: { example: 234567890 }
            requires :retailer_service_id, type: Integer, desc: 'Delivery Method of order', documentation: { example: 3 }
            requires :retailer_id, type: Integer, desc: 'ID of the retailer', documentation: { example: 16 }
            requires :payment_type_id, type: Integer, desc: 'ID of the payment type', documentation: { example: 2 }
            requires :vat, type: Integer, desc: 'Value Added TAX %'
            requires :products, type: Array do
              requires :amount, type: Integer, desc: 'Desired amount of product', documentation: { example: 5 }
              requires :product_id, type: Integer, desc: 'Desired amount of product', documentation: { example: 5 }
            end
            optional :shopper_address_id, type: Integer, desc: "ID of the shopper's address", documentation: { example: 16 }
            optional :delivery_slot_id, type: Integer, desc: 'Delivery Slot ID', documentation: { example: 16 }
            optional :estimate_delivery_time, type: String, desc: 'Estimated Delivery Time', documentation: { example: '2021-01-17 20:00:00' }
            optional :promotion_code_realization_id, type: Integer, desc: 'ID of the promotion code realization'
            optional :shopper_note, type: String, desc: 'Shopper note for retailer'
            optional :device_type, type: Integer, desc: "Shopper's device type (0 - Android, 1 - IOS, 2 - Web)"
            optional :collector_detail_id, type: Integer, desc: 'Collector Detail Id', documentation: { example: 3 }
            optional :vehicle_detail_id, type: Integer, desc: 'Vehicle Detail Id', documentation: { example: 3 }
            optional :pickup_location_id, type: Integer, desc: 'pickup location Id', documentation: { example: 3 }
          end

          put do
            I18n.locale = :en
            error!(CustomErrors.instance.not_allowed, 421) unless current_shopper
            error!(CustomErrors.instance.order_not_found, 421) unless order
            error!(CustomErrors.instance.shopper_not_have_order, 421) unless order.shopper_id == current_shopper.id
            error!(CustomErrors.instance.order_not_in_edit, 421) unless [-1, 8].include?(order.status_id)
            error!(CustomErrors.instance.products_empty, 421) if params[:products].empty?
            error!(CustomErrors.instance.retailer_not_found, 421) unless retailer
            error!(CustomErrors.instance.retailer_not_have_service, 421) unless retailer_has_service
            error!(CustomErrors.instance.payment_type_invalid, 421) unless payment_type
            error!(CustomErrors.instance.fraudster, 421) if shopper_online_payment_block
            case params[:retailer_service_id]
            when 1
              delivery_requirements
            when 2
              c_n_c_requirements
            end
            update_slot_validation
            validate_promotion_code
            Order.transaction do
              clear_order(order.id)
              create_positions!(order.id)
              order = update_order!
              update_collection_detail(order.id) if retailer_has_service.retailer_service_id == 2
              if promo_realization.present? # && promotion_code.can_be_used?(shopper_id, retailer_id)
                promo_realization.order_id = order.id
                promo_realization.discount_value = discount_value
                promo_realization.retailer_id = order.retailer_id unless payment_type.id == 3
                promo_realization.save
              else
                PromotionCodeRealization.where(order_id: order.id).update_all(retailer_id: nil, order_id: nil)
              end
            end
            retailer.update_order_notify(order.id) if order.status_id.zero?
            if order.retailer_service_id == 2
              remind_collector = SystemConfiguration.find_by(key: 'remind_collector')
              ::CollectorNotificationJob.set(wait_until: (order.estimated_delivery_at - Integer(remind_collector&.value || 30).minute)).perform_later(order.id)
            end
            ::SlackNotificationJob.perform_later(order.id)
            present order, with: API::V2::Orders::Entities::CreateOrderEntity
          end
        end
      end
    end
  end
end
