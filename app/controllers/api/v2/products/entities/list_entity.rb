module API
  module V2
    module Products
      module Entities
        class ListEntity < API::BaseEntity

          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'String', desc: 'Product retailer id' }
          expose :name, documentation: { type: 'String', desc: 'Products name' }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: 'URL friendly name' }, format_with: :string
          expose :description, documentation: { type: 'String', desc: 'Products description' }, format_with: :string
          expose :barcode, documentation: { type: 'String', desc: 'Products barcode' }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: 'An URL directing to a image of the product.' }, format_with: :string
          expose :full_image_url, documentation: { type: 'String', desc: 'An URL directing to a image of the product.' }, format_with: :string
          expose :size_unit, documentation: { type: 'String', desc: 'Products size unit' }, format_with: :string
          expose :price, as: :full_price, documentation: { type: 'Float', desc: 'Price of product' }, format_with: :float
          expose :price_currency, documentation: { type: 'String', desc: 'Price Currency' }, format_with: :string
          expose :promotion, using: API::V2::Products::Entities::ShopPromoEntity, documentation: { type: 'show_brand', is_array: true }
          expose :brand, using: API::V1::Brands::Entities::BrandInProductEntity, documentation: { type: 'show_brand', is_array: true }
          expose :categories, documentation: { type: 'name_entity', desc: 'Categories' } do |result, options|
            API::V1::Categories::Entities::CategoryInProductEntity.represent object.categories, except: [:is_show_brand]
          end
          expose :subcategories, documentation: { type: 'name_entity', desc: 'Subcategories' } do |result, options|
            API::V1::Categories::Entities::CategoryInProductEntity.represent object.subcategories, except: [:is_show_brand]
          end
          expose :is_available, documentation: { type: 'Boolean', desc: 'Is product disbale in shop?' }, format_with: :bool
          expose :is_published, documentation: { type: 'Boolean', desc: 'Is product published in shop?' }, format_with: :bool
          expose :is_promotional, as: :is_p, documentation: { type: 'Boolean', desc: 'Is product promotional in shop?' }, format_with: :bool
          expose :available_quantity, documentation: { type: 'Integer', desc: 'Available Quantity' }, format_with: :integer

          private

          def image_url
            object.photo.url(:medium)
          end

          def full_image_url
            object.photo.url(:medium)
          end

          def price
            if promotion.present?
              promotion.standard_price
            else
              object.price
            end
          end

          def is_promotional
            object.promotion_only
          end

          def promotion
            @promotion ||= object.retailer_shop_promotions.first
          end

          def available_quantity
            retailer_with_stock ? object&.available_for_sale.to_i : -1
          end

          def retailer_with_stock
            options[:retailer_with_stock]
          end

        end
      end
    end
  end
end
