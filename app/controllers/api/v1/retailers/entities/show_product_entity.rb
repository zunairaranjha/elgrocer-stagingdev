module API
  module V1
    module Retailers
      module Entities
        class ShowProductEntity < API::BaseEntity
          root 'products', 'product'
          def self.entity_name
            'show_product'
          end
        
          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'String', desc: 'Product retailer id' }
          expose :name, documentation: { type: 'String', desc: 'Products name' }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: "URL friendly name" }, format_with: :string
          expose :description, documentation: { type: 'String', desc: 'Products description' }, format_with: :string
          expose :barcode, documentation: { type: 'String', desc: 'Products barcode' }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a image of the product." }, format_with: :string
          expose :full_image_url, documentation: { type: 'String', desc: "An URL directing to a image of the product." }, format_with: :string
          expose :shelf_life, documentation: { type: 'Integer', desc: "Products shelf life" }, format_with: :integer
          expose :size_unit, documentation: { type: 'String', desc: "Products size unit" }, format_with: :string
          expose :is_local, documentation: { type: 'Boolean', desc: "Is product in local base?" }, format_with: :bool
          expose :price, using: API::V1::Products::Entities::ShowPriceEntity, documentation: {type: 'show_price', is_array: true }
          expose :country, using: API::V1::Countries::Entities::ShowEntity, documentation: {type: 'show_country', is_array: true }
          expose :is_available, documentation: { type: 'Boolean', desc: "Is product disbale in shop?" }, format_with: :bool
          expose :is_published, documentation: { type: 'Boolean', desc: "Is product published in shop?" }, format_with: :bool
        
          private
        
          def retailer_id
            options[:retailer_id]
          end
        
          def price
            # record = Shop.find_by(product_id: object.id, retailer_id: options[:retailer_id])
            record = shop
            result = nil
            if record
              result = {
                price_cents: record.price_cents,
                price_dollars: record.price_dollars,
                price_currency: record.price_currency
              }
            end
            result
          end
        
          def shop
            return object if object.try(:shop_id).to_i > 0
            return @shop = object.shops.detect {|s| s.retailer_id == options[:retailer_id] } if options[:retailer_id] && (object.association(:shops).loaded?)
            @shop ||= Shop.unscoped.find_by(product_id: object[:id], retailer_id: options[:retailer_id]) if options[:retailer_id]
          end
        
          def is_available
            shop.try(:is_available)
          end
        
          def is_published
            shop.try(:is_published)
          end
        
          def image_url
            result = object.photo.url(:medium)
            result
          end
        
          def full_image_url
            result = object.photo.url(:medium)
            result
          end
        
          def country
            Country[object.country_alpha2]
          end
        
        end                
      end
    end
  end
end