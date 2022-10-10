module API
  module V1
    module Products
      module Entities
        class ShowProductForShopper < API::BaseEntity
          root 'products', 'product'
          def self.entity_name
            'show_product_shopper'
          end
          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Products name' }, format_with: :string
          expose :description, documentation: { type: 'String', desc: 'Products description' }, format_with: :string
          expose :barcode, documentation: { type: 'String', desc: 'Products barcode' }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a image of the product." }, format_with: :string
          expose :full_image_url, documentation: { type: 'String', desc: "An URL directing to a image of the product." }, format_with: :string
          expose :shelf_life, documentation: { type: 'Integer', desc: "Products shelf life" }, format_with: :integer
          expose :size_unit, documentation: { type: 'String', desc: "Products size unit" }, format_with: :string
          expose :is_local, documentation: { type: 'Boolean', desc: "Is product in local base?" }, format_with: :bool
          expose :slug, documentation: { type: 'String', desc: "URL friendly name" }, format_with: :string
          expose :created_at, documentation: { type: 'String', desc: "Is product in local base?" }, format_with: :string
          expose :brand, using: API::V1::Brands::Entities::ShowEntity, documentation: {type: 'show_brand', is_array: true }
          expose :country, using: API::V1::Countries::Entities::ShowEntity, documentation: {type: 'pro_country', is_array: true }
        
          private
          def image_url
            object.photo.url(:medium)
          end
        
          def full_image_url
            object.photo.url(:medium)
          end
        
          def country
            Country[object.country_alpha2]
          end
        end                
      end
    end
  end
end