module API
  module V2
    module Products
      module Entities
        class ShopPromoEntity < API::BaseEntity
  
          def self.entity_name
            'shop_promotion_entity'
          end
  
          expose :price, documentation: { type: 'Float', desc: 'Promotion Price' }, format_with: :float
          expose :price_currency, documentation: { type: 'String', desc: 'Price Currency' }, format_with: :string
          expose :start_time, documentation: { type: 'Float', desc: 'Start Time' }, format_with: :float
          expose :end_time, documentation: { type: 'Float', desc: 'End Time' }, format_with: :float
          expose :product_limit, documentation: { type: 'Integer', desc: 'Product Limit' }, format_with: :integer
        end
      end
    end
  end
end