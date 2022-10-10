# frozen_string_literal: true

module API
  module V1
    module Products
      module Entities
        class ProductsEntity < API::V1::Products::Entities::ShowTopSellingEntity

          # ShowTopSellingEntity.root false, false

          expose :price, as: :full_price, documentation: { type: 'Float', desc: 'Price Of the product' }, format_with: :float, override: true
          expose :brand, using: API::V1::Brands::Entities::BrandInProductEntity, documentation: { type: 'show_brand', is_array: true }
          expose :categories, using: API::V1::Categories::Entities::CategoryInProductEntity, documentation: { type: 'name_entity', is_array: true }
          expose :subcategories, using: API::V1::Categories::Entities::CategoryInProductEntity, documentation: { type: 'name_entity', is_array: true }

          private

          def price
            if shop_promotion.present?
              shop_promotion&.price
            else
              (object.price_dollars + (object.price_cents).to_f / 100).round(2)
            end
          end
        end
      end
    end
  end
end