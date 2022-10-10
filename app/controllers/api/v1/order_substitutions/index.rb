module API
  module V1
    module OrderSubstitutions
      class Index < Grape::API
        # include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :order_substitutions do
          desc "Allows creation of an order substitutions", entity: API::V1::OrderSubstitutions::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: "Order ID", documentation: { example: 2 }
          end
      
          get do
            #This API is not used
            order = Order.find(params[:order_id])
            # OrderSubstitution.where(order_id: order.id)
            present order.order_substitutions, with: API::V1::OrderSubstitutions::Entities::ShowEntity, documentation: { type: 'order_substitution' }
          end
        end
      end
    end
  end
end