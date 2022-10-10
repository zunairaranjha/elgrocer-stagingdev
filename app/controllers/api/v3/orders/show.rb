# frozen_string_literal: true

module API
  module V3
    module Orders
      class Show < Grape::API
        version 'v3', using: :path
        format :json

        resource :orders do
          desc 'Find order by order id.', entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: 'Order id', documentation: { example: '7894900011593' }
            optional :version, type: Integer, desc: 'Info for Version Number', documentation: { example: 1 }
          end

          get '/show' do
            order = Order.select(:id, :retailer_id).find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            Product.retailer_of_product = order&.retailer_id
            order = Order.where(id: order.id)
            order = order.includes(:credit_card, :delivery_slot, { promotion_code_realization: :promotion_code })
            order = order.includes({ order_positions_views: [:product, { order_subs_view: [
                                     :shop_promotion, { product_proposal: %i[brand categories subcategories] },
                                     { substituting_product: %i[
                                       brand categories subcategories retailer_shops] }] }] })
            order = order.includes(:collector_detail, :pickup_loc, vehicle_detail: %i[color vehicle_model])
            order = order.includes(:orders_datum)
            for_employee = request.headers['Employee'].to_i.positive?
            order = order.includes({ analytics: :event }) if for_employee
            API::V3::Orders::Entities::ShowOrderEntity.represent order.first, retailer: for_employee, retailer_with_stock: Retailer.stock_level(Product.retailer_of_product).exists?, root: false, for_web: request.headers['Referer'].present?
          end
        end
      end
    end
  end
end
