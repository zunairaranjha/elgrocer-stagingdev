# frozen_string_literal: true

module API
  module V1
    module Webhooks
      class ShopperDetail < Grape::API
        version 'v1', using: :path
        format :json

        resource :webhooks do
          params do
            optional :shopper_id, type: Integer, desc: 'Id of the shopper', documentation: { example: 35099 }
            optional :shopper_email, type: String, desc: 'Email of the shopper', documentation: { example: 'eample@eample.com' }
            optional :shopper_phone_number, type: String, desc: 'Shopper Phone number', documentation: { example: '3456234567' }
            optional :order_id, type: Integer, desc: 'Order ID', documentation: { example: 3456789767 }
          end

          get '/shopper_detail' do
            if params[:shopper_id]
              shopper = Shopper.find_by(id: params[:shopper_id])
            elsif params[:shopper_email]
              shopper = Shopper.find_by(email: params[:shopper_email])
            elsif params[:shopper_phone_number]
              shopper = Shopper.where("phone_number like '%#{params[:shopper_phone_number]}'").first
            else
              error!(CustomErrors.instance.params_missing, 421)
            end
            error!(CustomErrors.instance.shopper_not_found, 421) unless shopper
            orders = Order.includes(:picker, :delivery_slot, promotion_code_realization: [:promotion_code]).joins(:order_positions).where(shopper_id: shopper.id)
            orders = orders.where(id: params[:order_id]) if params[:order_id]
            orders = orders.select("orders.*, COALESCE(sum(case when order_positions.was_in_shop = 't' then order_positions.amount end), 0) AS total_products")
            orders = orders.order("created_at DESC").group("orders.id").first(4)
            result = {
              shopper: shopper,
              latest_orders: orders
            }
            present result, with: API::V1::Webhooks::Entities::ShopperDetailEntity
          end
        end
      end
    end
  end
end