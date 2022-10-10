# frozen_string_literal: true

module API
  module V2
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
          expose :brand, using: API::V1::Brands::Entities::ShowEntity, documentation: {type: 'show_brand', is_array: true }
          expose :categories, using: API::V1::Products::Entities::ShowNameEntity, documentation: {type: 'name_entity', is_array: true }
          expose :subcategories, using: API::V1::Products::Entities::ShowNameEntity, documentation: {type: 'name_entity', is_array: true }
          #expose :categories, documentation: {type: 'subcategory', is_array: true }do |result, options|
          #  API::V2::Retailers::Entities::ShowCategoryEntity.represent result.categories, options.merge(product_id: object.id)
          #end
          expose :is_available, documentation: { type: 'Boolean', desc: "Is product disbale in shop?" }, format_with: :bool
          expose :is_published, documentation: { type: 'Boolean', desc: "Is product published in shop?" }, format_with: :bool
          expose :is_promotional, as: :is_p, documentation: { type: 'Boolean', desc: "Is product promotional in shop?" }, format_with: :bool
          private
        
          # def retailer_id
          #   options[:retailer_id]
          # end
        
          # def shop
          #   return object if object.try(:shop_id).to_i > 0
          #   return @shop ||= object.shops.detect {|s| s.retailer_id == options[:retailer_id] } if options[:retailer_id] && (object.association(:shops).loaded?)
          #   @shop ||= Shop.unscoped.find_by(product_id: object[:id], retailer_id: options[:retailer_id]) if options[:retailer_id]
          # end
        
          # def is_available
          #   shop.try(:is_available)
          # end
          #
          # def is_published
          #   shop.try(:is_published)
          # end
          #
          # def is_promotional
          #   shop.try(:is_promotional)
          # end

          def price
            # record = Shop.find_by(product_id: object.id, retailer_id: options[:retailer_id])
            record = object
            result = nil
            if record && shop_promotion.present?
              result = {
                price_cents: ((shop_promotion.price - shop_promotion.price.to_i) * 100).round,
                price_dollars: shop_promotion.price.to_i,
                price_currency: shop_promotion.price_currency
              }
            else
              result = {
                price_cents: record.price_cents,
                price_dollars: record.price_dollars,
                price_currency: record.price_currency
              }
            end
            result
          end

          def is_promotional
            object.is_promotional && shop_promotion.present?
          end

          def shop_promotion
            @promotion ||= object.shop_promotions.first
          end

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