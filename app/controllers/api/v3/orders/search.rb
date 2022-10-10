# frozen_string_literal: true

module API
  module V3
    module Orders
      class Search < Grape::API
        include TokenAuthenticable
        version 'v3', using: :path
        format :json

        resource :orders do
          desc 'Allow search order from id'

          params do
            requires :search_input, type: Integer, desc: 'Order Id', documentation: { example: 2345678 }
            optional :retailer_id, type: Integer, desc: 'retailer_id', documentation: { example: 10 }
          end

          get '/search' do
            error!(CustomErrors.instance.only_for_employee) if current_shopper
            retailer_id = params[:retailer_id] ? params[:retailer_id] : current_employee.retailer_id
            Product.retailer_of_product = retailer_id
            order = Order.where(id: params[:search_input], retailer_id: retailer_id)
            order = order.joins("LEFT OUTER JOIN order_allocations ON order_allocations.order_id = orders.id AND order_allocations.is_active = 't'")
            order = order.joins('LEFT OUTER JOIN employees ON employees.id = order_allocations.employee_id').group('orders.id')
            order = order.select('orders.*, (ARRAY_AGG(employees.user_name))[1:1] AS employee_name')
            order = order.includes(:credit_card, :delivery_slot, { promotion_code_realization: :promotion_code })
            order = order.includes({ order_positions_views: [:product, :order, { order_subs_view: [
                                     :shop_promotion, { product_proposal: %i[brand categories subcategories] },
                                     { substituting_product: %i[
                                       brand categories subcategories retailer_shops] }] }] })
            order = order.includes(:collector_detail, :pickup_loc, vehicle_detail: %i[color vehicle_model])
            order = order.includes(:orders_datum, { analytics: :event })
            result = order.first
            if result
              API::V3::Orders::Entities::ShowOrderEntity.represent result, root: false, retailer: true
            else
              error!(CustomErrors.instance.order_not_found, 421)
            end
          end
        end
      end
    end
  end
end
