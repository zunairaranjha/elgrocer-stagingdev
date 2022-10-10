module API
  module V1
    module Orders
      class Show < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :orders do
          desc "Find order by order id.", entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: 'Order id', documentation: { example: '7894900011593' }
            optional :version, type: Integer, desc: 'Info for Version Number', documentation: { example: 1 }
          end
          route_param :order_id do
            get do
              target_user = current_retailer || current_shopper
              order = Order.where(id: params[:order_id])
              order = order.includes(:credit_card, {order_positions: :product}, {promotion_code_realization: :promotion_code}, :delivery_slot, {order_substitutions: [substituting_product: [:brand, :categories, :subcategories]]})
              order = order.includes({retailer: [:available_payment_types, :city]}, :retailer_delivery_zone) if target_user.class.name.downcase.eql?("shopper")
              order = order.includes({analytics: :event}) if target_user.class.name.downcase.eql?("retailer")
              result = order.first
              #result = Order.includes({order_positions: :product}, {promotion_code_realization: [:promotion_code]}, {retailer: [:available_payment_types, :city]}, :delivery_slot, {order_substitutions: [substituting_product: :brand]}, {analytics: :event}).find(params[:order_id])
              if result.valid?
                present result, with: API::V1::Orders::Entities::ShowEntity, retailer: target_user.class.name.downcase.eql?("retailer"), v1: (headers['Employee'].to_i < 1 or params[:version].to_i < 1)
              else
                error!({error_code: 403, error_message: "Order does not exist"},403)
              end
            end
          end
        end
      end      
    end
  end
end