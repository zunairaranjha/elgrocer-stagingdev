module API
  module V1
    module OrderSubstitutions
      module Entities
        class ShowEntity < API::BaseEntity
          root 'order_substitutions', 'order_substitution'
          def self.entity_name
            'order_substitution'
          end
        
          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :shopper_id, documentation: { type: 'Integer', desc: 'ID of the shopper' }, format_with: :integer
          expose :order_id, documentation: { type: 'Integer', desc: "Order ID"}, format_with: :integer
          expose :product_id, documentation: { type: 'Integer', desc: 'ID of the status' }, format_with: :integer
          expose :substituting_product_id, documentation: { type: 'Integer', desc: 'ID of the payment_type_id' }, format_with: :integer
          expose :is_selected, documentation: { type: 'Boolean', desc: "Choosen subsitution by user" }, format_with: :bool
        end        
      end
    end
  end
end