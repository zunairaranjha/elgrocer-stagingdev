# frozen_string_literal: true

module API
  module V1
    module Webhooks
      class OrderDetail < Grape::API
        version 'v1', using: :path
        format :json

        resource :webhooks do
          desc 'Order Detail with Shopper'

          params do
            requires :order_id, type: Integer, desc: 'Order Id', documentation: { example: 12345678 }
          end

          get '/order_detail' do
            orders = Order.includes(:picker, :delivery_slot, promotion_code_realization: [:promotion_code]).joins(:order_positions)
            orders = orders.where(id: params[:order_id])
            orders = orders.select("orders.*, COALESCE(sum(case when order_positions.was_in_shop = 't' then order_positions.amount end), 0) AS total_products")
            orders = orders.order("created_at DESC").group("orders.id").first
            error!(CustomErrors.instance.order_not_found, 421) unless orders
            result = {
              order: orders,
              shopper: orders.shopper
            }
            present result, with: API::V1::Webhooks::Entities::OrderShopperDetailEntity
          end
        end
      end
    end
  end
end
