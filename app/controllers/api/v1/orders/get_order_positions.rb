module API
  module V1
    module Orders
      class GetOrderPositions < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :orders do
          desc "lists all orders of a shopper or retailer (depending on who is requesting it)", entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_ids, type: String, desc: 'Ids of order', documentation: { example: '123434,132323,2345689'}
          end
      
          get '/show/order_positions' do
            order_positions = OrderPosition.joins(:order).where(order_id: params[:order_ids].split(',').reject(&:empty?).map(&:to_i))
            order_positions = order_positions.includes(:product, {order: [order_substitutions: [substituting_product: [:brand, :categories, :subcategories]]]})
            present order_positions, with: API::V1::Orders::Entities::ShowPositionEntity, retailer: current_employee
          end
        end
      end      
    end
  end
end