# frozen_string_literal: true

module API
  module V1
    module Products
      module Entities
        class ShowProduct < API::BaseEntity
          def self.entity_name
            'show_name'
          end
          expose :product, using: API::V1::Products::Entities::ShowEntity, documentation: {type: 'show_product', is_array: true }
          # expose :retailer_id, documentation: { type: 'Integer', desc: "Shop Id" }, format_with: :integer
          expose :in_shop, documentation: { type: 'Boolean', desc: "Is product in my shop?" }, format_with: :bool
          expose :shop_id, documentation: { type: 'Integer', desc: "Shop Id" }, format_with: :integer
          expose :is_available, documentation: { type: 'Boolean', desc: "Is product disbale in shop?" }, format_with: :bool
          expose :is_published, documentation: { type: 'Boolean', desc: "Is product published in shop?" }, format_with: :bool
        
          private
        
          def shop
            @shop ||= Shop.find_by({retailer_id: object[:retailer_id], product_id: object[:product].try(:id)})
          end
        
          def in_shop
            # object[:product].in_shop(object[:retailer_id])
            shop.present? ? true : false
          end
        
          def shop_id
            shop.try(:id)
          end
        
          def is_available
            shop.try(:is_available)
          end
        
          def is_published
            shop.try(:is_published)
          end
        end
        
        class IndexEntity < API::BaseEntity
          expose :products, using: API::V1::Products::Entities::ShowProduct, documentation: {type: 'show_name', is_array: true }
        end        
      end
    end
  end
end