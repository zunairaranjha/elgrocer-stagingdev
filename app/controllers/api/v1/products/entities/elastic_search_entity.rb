# frozen_string_literal: true

module API
  module V1
    module Products
      module Entities
        class ElasticSearchEntity < API::BaseEntity
          root 'products', 'product'
          def self.entity_name
            'show_product'
          end
        
          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'String', desc: 'Product retailer id' }
          expose :name, documentation: { type: 'String', desc: 'Products name' }, format_with: :string
          expose :description, documentation: { type: 'String', desc: 'Products description' }, format_with: :string
          expose :barcode, documentation: { type: 'String', desc: 'Products barcode' }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a image of the product." }, format_with: :string
          expose :full_image_url, documentation: { type: 'String', desc: "An URL directing to a image of the product." }, format_with: :string
          expose :shelf_life, documentation: { type: 'Integer', desc: "Products shelf life" }, format_with: :integer
          expose :size_unit, documentation: { type: 'String', desc: "Products size unit" }, format_with: :string
          expose :is_local, documentation: { type: 'Boolean', desc: "Is product in local base?" }, format_with: :bool
          expose :price, using: API::V1::Products::Entities::ShowPriceEntity, documentation: {type: 'show_price', is_array: true }
          expose :brand, using: API::V1::Products::Entities::ShowEsBrandEntity, documentation: {type: 'show_es_brand', is_array: true }
          expose :country, using: API::V1::Countries::Entities::ShowEntity, documentation: {type: 'show_country', is_array: true }
          expose :categories, using: API::V1::Products::Entities::ShowCategoryEntity, documentation: {type: 'show_category', is_array: true }
          expose :in_shop, documentation: { type: 'Boolean', desc: "Is product in shop?" }, format_with: :bool
          expose :is_promotional, as: :is_p, documentation: { type: 'Boolean', desc: "Is product promotional in shop?" }, format_with: :bool
          expose :product_rank, documentation: {type: Float, desc: "product rank based on sales"}
        
          private
          def product_rank
            object[:_source][:product_rank]
          end
        
          def retailer_id
            object[:_source][:retailer_id]
          end
        
          def id
            object[:_source][:id]
          end
        
          def name
            object[:_source][:name]
          end
        
          def description
            object[:_source][:description]
          end
        
          def barcode
            object[:_source][:barcode]
          end
        
          def image_url
            object[:_source][:image_url]
          end
        
          def full_image_url
            object[:_source][:full_image_url]
          end
        
          def shelf_life
            object[:_source][:shelf_life]
          end
        
          def size_unit
            object[:_source][:size_unit]
          end
        
          def is_local
            object[:_source][:is_local]
          end
        
          def brand
            object[:_source][:brand]
          end
        
          def country
            object[:_source][:country]
          end
        
          def categories
            object[:_source][:categories]
          end
        
          def is_published
            object[:_source][:is_published]
          end
        
          def is_available
            object[:_source][:is_available]
          end
        
          def is_promotional
            object[:_source][:is_p]
          end
        
          def price
            # shop = Shop.find_by(product_id: object[:_source][:id], retailer: options[:retailer].id)
            # shop ? {price_dollars: shop.price_dollars, price_cents: shop.price_cents, price_currency: shop.price_currency} : nil
            object[:_source][:price]
          end
        
          def in_shop
            # Shop.exists?(product_id: object[:_source][:id], retailer: options[:retailer].id)
            true
          end
        
        end        
      end
    end
  end
end