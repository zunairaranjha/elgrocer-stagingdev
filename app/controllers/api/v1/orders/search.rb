module API
  module V1
    module Orders
      class Search < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :orders do
          desc "lists all orders of a shopper or retailer (depending on who is requesting it)", entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :search_input, type: String, desc: 'Search input', documentation: { example: 'CocaCola' }
          end
      
          get '/search' do
            search_input = params[:search_input] || ''
            target_user = current_retailer || current_shopper
            if current_retailer
              orders = target_user.orders.where(retailer_deleted: false)
            else
              orders = target_user.orders.where({shopper_deleted: false, status_id: 3})
            end
      
            # orders = orders.where(status_id: params[:status_id]) if params[:status_id]
            if !search_input[/\p{L}/] and search_input.to_i > 0
              orders = orders.where(id: search_input)
            else
              orders = orders.where(status_id: 3).where("LOWER(orders.shopper_name) LIKE '%" + search_input + "%' OR LOWER(orders.retailer_company_name) LIKE '%" + search_input + "%' OR orders.id IN (SELECT DISTINCT(order_positions.order_id) FROM order_positions WHERE LOWER(order_positions.product_name) LIKE '%" + search_input + "%')")
            end
            orders = orders.includes(:credit_card, {order_positions: :product}, {promotion_code_realization: :promotion_code}, :delivery_slot, {order_substitutions: [substituting_product: [:brand, :categories, :subcategories]]})
            orders = orders.includes({retailer: [:available_payment_types, :city]}, :retailer_delivery_zone) if current_shopper
            orders = orders.includes({analytics: :event}) if current_retailer
            orders = orders.order("created_at DESC")
      
            present orders, with: API::V1::Orders::Entities::ShowEntity, retailer: current_retailer, v1: true
          end
        end
      end      
    end
  end
end