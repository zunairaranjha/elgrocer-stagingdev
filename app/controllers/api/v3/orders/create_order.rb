# frozen_string_literal: true

module API
  module V3
    module Orders
      class CreateOrder < Grape::API
        include TokenAuthenticable
        helpers Concerns::OrderParamHelper
        helpers Concerns::CreateUpdateOrderHelper
        helpers Concerns::SmilesHelper
        version 'v3', using: :path
        format :json
        resources :orders do
          desc 'Allows creation of an order'
          params do
            use :create_order_param
          end

          post '/post' do
            create_validations
            order = Order.transaction do
              order = create_order
              create_positions!(order.id)
              create_collection_detail(order.id) if params[:retailer_service_id] == 2
              promotion_on_order(order)
              order_substitution_preference(order.id)
              order
            end
            if order.status_id.zero?
              # retailer.new_order_notify(order.id)
              ShopperMailer.order_placement(order.id).deliver_later
              ::ShopperCartProducts::Delete.run({retailer_id: retailer.id, shopper_id: current_shopper.id}) rescue ''
            end
            if params[:retailer_service_id] == 2
              remind_collector = SystemConfiguration.find_by(key: 'remind_collector')
              ::CollectorNotificationJob.set(wait_until: (order.estimated_delivery_at - Integer(remind_collector&.value || 30).minute)).perform_later(order.id)
            end
            ::SlackNotificationJob.perform_later(order.id)
            Resque.enqueue(PartnerIntegrationJob, order.id)
            API::V3::Orders::Entities::CreateOrderEntity.represent order, root: false
          end
        end

        resources :orders do
          helpers Concerns::CheckShopAvailabilityHelper
          desc 'Create an Order'
          params do
            use :create_order_param
          end

          post '/generate' do
            create_validations
            check_products_quantity
            order = Order.transaction do
              order = create_order
              create_positions!(order.id)
              adjust_stock
              create_collection_detail(order.id) if params[:retailer_service_id] == 2
              promotion_on_order(order)
              order_substitution_preference(order.id)
              debit_smiles_points(order) if params[:payment_type_id] == 4 && order.total_price.positive?
              #===================== To check shopper subscription status and Tier in smiles:
              # get_shopper_smiles_info(current_shopper, order) if order.platform_type.eql?('smiles') && params[:payment_type_id] != 4
              order
            end
            if order.status_id.zero?
              # retailer.new_order_notify(order.id)
              ShopperMailer.order_placement(order.id).deliver_later
              ::ShopperCartProducts::Delete.run({retailer_id: retailer.id, shopper_id: current_shopper.id}) rescue ''
            end
            if params[:retailer_service_id] == 2
              remind_collector = SystemConfiguration.find_by(key: 'remind_collector')
              ::CollectorNotificationJob.set(wait_until: (order.estimated_delivery_at - Integer(remind_collector&.value || 30).minute)).perform_later(order.id)
            end
            ::SlackNotificationJob.perform_later(order.id)
            Resque.enqueue(PartnerIntegrationJob, order.id)
            API::V3::Orders::Entities::CreateOrderEntity.represent order, root: false
          end
        end
      end
    end
  end
end
