# frozen_string_literal: true

module API
  module V1
    module Products
      module Entities
        class ShowEntity < API::BaseEntity
          root 'products', 'product'

          def self.entity_name
            'show_product'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'String', desc: 'Product retailer id' }, :if => Proc.new { |product| options[:retailer] }
          expose :name, documentation: { type: 'String', desc: 'Products name' }, format_with: :string
          expose :description, documentation: { type: 'String', desc: 'Products description' }, format_with: :string
          expose :barcode, documentation: { type: 'String', desc: 'Products barcode' }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a image of the product." }, format_with: :string
          expose :full_image_url, documentation: { type: 'String', desc: "An URL directing to a image of the product." }, format_with: :string
          expose :shelf_life, documentation: { type: 'Integer', desc: "Products shelf life" }, format_with: :integer
          expose :size_unit, documentation: { type: 'String', desc: "Products size unit" }, format_with: :string
          expose :is_local, documentation: { type: 'Boolean', desc: "Is product in local base?" }, format_with: :bool
          expose :slug, documentation: { type: 'String', desc: "URL friendly name" }, format_with: :string
          expose :in_shop, documentation: { type: 'Boolean', desc: "Is product in shop?" }, format_with: :bool, :if => Proc.new { |product| options[:retailer] }
          expose :shop_id, documentation: { type: 'Integer', desc: "Shop Id" }, format_with: :integer, :if => Proc.new { |product| options[:retailer] }
          expose :is_available, documentation: { type: 'Boolean', desc: "Is product disbale in shop?" }, format_with: :bool, :if => Proc.new { |product| options[:retailer] }
          expose :is_published, documentation: { type: 'Boolean', desc: "Is product published in shop?" }, format_with: :bool, :if => Proc.new { |product| options[:retailer] }
          expose :is_promotional, as: :is_p, documentation: { type: 'Boolean', desc: "Is product promotional in shop?" }, format_with: :bool, :if => Proc.new { |product| options[:retailer] }
          expose :price, using: API::V1::Products::Entities::ShowPriceEntity, documentation: { type: 'show_price', is_array: true }, :if => Proc.new { |product| options[:retailer] }
          expose :brand, using: API::V1::Brands::Entities::ShowEntity, documentation: { type: 'show_brand', is_array: true }
          expose :country, using: API::V1::Countries::Entities::ShowEntity, documentation: { type: 'show_country', is_array: true }
          expose :categories_hash, using: API::V1::Products::Entities::ShowCategoryEntity, as: :categories, documentation: { type: 'show_category', is_array: true }
          # expose :categories, using: API::V1::Products::Entities::ShowCategoryEntity, documentation: {type: 'show_category', is_array: true }

          private

          def retailer_id
            shop.try(:retailer_id) || options[:retailer]&.id
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

          def is_promotional
            shop.try(:is_promotional) && shop_promotion.present?
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

          def price
            if shop_promotion.present?
              result = {
                price_cents: ((shop_promotion.price - shop_promotion.price.to_i) * 100).round,
                price_dollars: shop_promotion.price.to_i,
                price_currency: shop_promotion.price_currency
              }
            elsif shop.present?
              result = {
                price_cents: shop.price_cents,
                price_dollars: shop.price_dollars,
                price_currency: shop.price_currency
              }
            else
              return nil
            end
            result
          end

          def shop
            return object if object.try(:shop_id).to_i > 0
            return @shop ||= object.shops.detect { |s| s.retailer_id == options[:retailer].id } if options[:retailer] && (object.association(:shops).loaded?)
            @shop ||= Shop.unscoped.find_by(product_id: object[:id], retailer_id: options[:retailer].id) if options[:retailer]
          end

          def categories_hash
            final_result = object.categories.map do |cat|
              result = {
                id: cat.id,
                name: cat.name,
                name_ar: cat.name_ar,
                image_url: cat.photo_url,
                is_show_brand: (cat.current_tags.include?(Category.tags[:is_show_brand])),
                is_food: (cat.current_tags.include?(Category.tags[:is_food])),
                pg_18: (cat.current_tags.include?(Category.tags[:pg_18]))
              }

              result[:children] = object.subcategories.map do |child|
                result_child = {
                  id: child.id,
                  name: child.name,
                  name_ar: child.name_ar,
                  image_url: child.photo_url,
                  is_show_brand: (child.current_tags.include?(Category.tags[:is_show_brand])),
                  is_food: (child.current_tags.include?(Category.tags[:is_food])),
                  pg_18: (child.current_tags.include?(Category.tags[:pg_18]))
                }
              end
              result
            end
            final_result
          end

        end
      end
    end
  end
end
