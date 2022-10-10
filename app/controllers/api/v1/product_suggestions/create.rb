module API
  module V1
    module ProductSuggestions
      class Create < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :product_suggestions do
          desc "Allows creation ", entity: API::V1::ProductSuggestions::Entities::ShowEntity
          params do
            optional :shopper_id, type: Integer, desc: "Shopper ID",documentation: { example: 16 }
            requires :retailer_id, type: Integer, desc: "ID of the retailer", documentation: { example: 16 }
            requires :products, type: Array do
              requires :name, type: String, desc: "Name of Suggested product", documentation: { example: "name1"}
            end
          end
              post do
                products=[]
                params[:products].each do |product|
                  products<<ProductSuggestion.create(name: product[:name], retailer_id: params[:retailer_id],shopper_id: params[:shopper_id])
                end
                products
              end
        end
      end      
    end
  end
end