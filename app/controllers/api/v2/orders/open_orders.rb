# frozen_string_literal: true

module API
  module V2
    module Orders
      class OpenOrders < Grape::API
        include TokenAuthenticable
        version 'v2', using: :path
        format :json

        resource :orders do
          desc 'Show Open Orders for current Shopper'

          get '/show/open_orders' do
            error!(CustomErrors.instance.not_allowed, 421) unless current_shopper
            current_shopper.update(language: request.headers['Locale']) if request.headers['Locale']
            system_conf = (Redis.current.get('complete_order_show_time') ||
              SystemConfiguration.find_by(key: 'complete_order_show_time')&.value).to_i
            orders = Order.where(shopper_id: current_shopper.id)
            orders = orders.where("orders.status_id IN (-1,0,1,2,6,7,8,9,11,12) or (orders.status_id IN (3,4,5) AND orders.updated_at > '#{Time.now - system_conf.minute}')")
            orders = orders.order('orders.created_at DESC')
            orders = orders.includes(:delivery_slot)
            present orders, with: API::V2::Orders::Entities::OpenOrderListEntity
          end

          desc 'To Get Open Order Detail'

          params do
            requires :order_id, type: Integer, desc: 'Order Id', documentation: {example: 12345678}
          end

          get '/show/open_order_detail' do
            error!(CustomErrors.instance.not_allowed, 421) unless current_shopper
            order = Order.where(shopper_id: current_shopper.id, id: params[:order_id])
            order = order.includes(:delivery_slot, :active_employee, :collector_detail, :pickup_loc,
                                   vehicle_detail: %i[color vehicle_model])
            order = order.first
            error!(CustomErrors.instance.order_not_found, 421) unless order
            present order, with: API::V2::Orders::Entities::OpenOrderDetailEntity
          end
        end
      end
    end
  end
end
