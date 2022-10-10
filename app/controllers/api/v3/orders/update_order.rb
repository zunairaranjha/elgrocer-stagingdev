# frozen_string_literal: true

module API
  module V3
    module Orders
      class UpdateOrder < Grape::API
        include TokenAuthenticable
        helpers Concerns::OrderParamHelper
        helpers Concerns::CreateUpdateOrderHelper
        helpers Concerns::SmilesHelper
        version 'v3', using: :path
        format :json

        resource :orders do
          desc 'Allows update of an order'
          params do
            requires :order_id, type: Integer, desc: 'Order Id to Update', documentation: { example: 234567890 }
            use :create_order_param
          end

          put '/update' do
            update_validation
            Order.transaction do
              clear_order(order.id)
              create_positions!(order.id)
              order = update_order!
              update_collection_detail(order.id) if params[:retailer_service_id] == 2
              promotion_on_order(order)
              order_substitution_preference(order.id)
            end
            # retailer.update_order_notify(order.id) if order.status_id.zero?
            if params[:retailer_service_id] == 2
              remind_collector = SystemConfiguration.find_by(key: 'remind_collector')
              ::CollectorNotificationJob.set(wait_until: (order.estimated_delivery_at - Integer(remind_collector&.value || 30).minute)).perform_later(order.id)
            end
            ::SlackNotificationJob.perform_later(order.id)
            API::V3::Orders::Entities::CreateOrderEntity.represent order, root: false
          end
        end

        resources :orders do
          helpers Concerns::CheckShopAvailabilityHelper
          desc 'Create an Order'
          params do
            requires :order_id, type: Integer, desc: 'Order Id to Update', documentation: { example: 234567890 }
            use :create_order_param
            optional :same_card, type: Boolean, desc: 'Same Card', documentation: { example: true }
          end

          put '/generate' do
            update_validation
            check_products_quantity
            Order.transaction do
              clear_order(order.id)
              create_positions!(order.id)
              adjust_stock
              order = update_order!
              update_collection_detail(order.id) if params[:retailer_service_id] == 2
              promotion_on_order(order)
              if order.payment_type_id == 3 && order.status_id == -1 && params[:same_card] && order.card_detail.present? && order.card_detail['is_void'].to_i.zero? && order.card_detail['auth_amount'].present?
                order_total_value = order.total_price
                if order.card_detail['auth_amount'].to_i / 100.0 >= order_total_value
                  order.update(status_id: 0)
                elsif order.card_detail['auth_amount'].to_i / 100.0 < order_total_value
                  AdyenJob.perform_later('auth_amount_changed', order)
                end
              end
              order_substitution_preference(order.id)
              Redis.current.del("order_#{order.id}")
            end
            # retailer.update_order_notify(order.id) if order.status_id.zero?
            if params[:retailer_service_id] == 2
              remind_collector = SystemConfiguration.find_by(key: 'remind_collector')
              ::CollectorNotificationJob.set(wait_until: (order.estimated_delivery_at - Integer(remind_collector&.value || 30).minute)).perform_later(order.id)
            end
            Resque.enqueue(WarehouseJob, { modify_order: true, order_id: order.id })
            ::SlackNotificationJob.perform_later(order.id)
            API::V3::Orders::Entities::CreateOrderEntity.represent order, root: false
          end
        end
      end
    end
  end
end
