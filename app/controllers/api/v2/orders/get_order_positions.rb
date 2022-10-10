# frozen_string_literal: true

module API
  module V2
    module Orders
      class GetOrderPositions < Grape::API
        include TokenAuthenticable
        version 'v2', using: :path
        format :json

        resource :orders do
          desc 'Product list of orders'
          params do
            requires :order_ids, type: String, desc: 'Ids of order', documentation: { example: '123434,132323,2345689' }
          end

          get '/show/order_positions' do
            order_ids = params[:order_ids].split(',').reject(&:empty?).map(&:to_i)
            Product.retailer_of_product = Order.select(:id, :retailer_id).find_by(id: order_ids[0])&.retailer_id
            order_positions = OrderPositionsView.where(order_id: order_ids)
            order_positions = order_positions.joins('INNER JOIN orders ON orders.id = order_positions_view.order_id')
            order_positions = order_positions.includes(:product, { order_subs_view: [
                                                         :shop_promotion, { product_proposal: %i[brand categories subcategories] },
                                                         { substituting_product: %i[
                                                           brand categories subcategories retailer_shops] }] })
            order_positions = order_positions.order('pickup_priority')
            present order_positions, with: API::V2::Orders::Entities::OrderPositionEntity, retailer: current_employee
          end
        end
      end
    end
  end
end
