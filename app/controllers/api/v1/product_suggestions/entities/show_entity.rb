module API
  module V1
    module ProductSuggestions
      module Entities
        class ShowEntity< API::BaseEntity
          expose :id, documentation: { type: 'Integer', desc: "ID of the Product Suggestion" }, format_with: :integer
          expose :shopper_name, documentation: { type: 'String', desc: "Shopper's name"}, format_with: :string
          expose :retailer_name, documentation: { type: 'String', desc: "Retailer's name"}, format_with: :string
          expose :created_at, documentation: { type: 'String', desc: "Products Suggestion creation date"}, format_with: :string
        
          private
        
          def shopper_name
            shopper = Shopper.find_by(:id => object.shopper_id)
            if shopper
              shopper.name
            else
              ''
            end
          end
        
          def retailer_name
            retailer = Retailer.find_by(:id => object.retailer_id)
            if retailer
              retailer.name
            else
              'Retailer Deleted'
            end
          end
        
        
        
        end                
      end
    end
  end
end