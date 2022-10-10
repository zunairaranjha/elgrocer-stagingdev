# frozen_string_literal: true

module API
  module V2
    module Orders
      module Entities
        class ShowSubstitutionProduct < API::V1::Orders::Entities::ShowSubstitutionProduct
          unexpose :shelf_life
          unexpose :is_local
          unexpose :country
          unexpose :price
          expose :brand, using: API::V1::Brands::Entities::BrandInProductEntity, documentation: { type: 'show_brand', is_array: true }
          expose :categories, documentation: { type: 'name_entity', desc: 'Categories' } do |result, options|
            API::V1::Categories::Entities::CategoryInProductEntity.represent object.categories, except: [:is_show_brand]
          end
          expose :subcategories, documentation: { type: 'name_entity', desc: 'Subcategories' } do |result, options|
            API::V1::Categories::Entities::CategoryInProductEntity.represent object.subcategories, except: [:is_show_brand]
          end
          expose :full_price, documentation: { type: 'Float', desc: 'Full dollars of the price' }, format_with: :float
          expose :price_currency, documentation: { type: 'String', desc: "Order's product price currency" }, format_with: :string
          expose :promotion, using: API::V2::Products::Entities::ShopPromoEntity, documentation: { type: 'show_brand', is_array: true }
          expose :available_quantity, documentation: { type: 'Integer', desc: 'Available Quantity' }, format_with: :integer
          expose :is_proposal_product, documentation: { type: 'Boolean', desc: 'Is product promotional in shop?' }, format_with: :bool

          def full_price
            if promotion.present?
              promotion.standard_price
            else
              (shop&.price_dollars.to_i + (shop&.price_cents).to_f / 100).round(2)
            end
          end

          def price_currency
            shop&.price_currency || promotion&.price_currency
          end

          def shop
            object.retailer_shops.first
          end

          def is_available
            available_quantity.negative? ? shop&.is_available : shop&.is_available && available_quantity.positive?
          end

          def is_published
            shop&.is_published
          end

          def is_promotional
            shop&.promotion_only
          end

          def promotion
            options[:shop_promotion]
          end

          def retailer_id
            shop&.retailer_id || promotion&.retailer_id
          end

          def available_quantity
            options[:retailer_with_stock] ? shop&.available_for_sale.to_i : -1
          end

          def is_proposal_product
            false
          end
        end
      end
    end
  end
end
