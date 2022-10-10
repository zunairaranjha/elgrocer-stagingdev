# frozen_string_literal: true

module API
  module V1
    module Orders
      module Entities
        class ShowProductProposal < API::V1::Orders::Entities::ShowSubstitutionProduct
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

          def id
            object.product_id
          end

          def full_price
            if object.is_promotion_available
              object.promotional_price
            else
              object.price
            end
          end

          def price_currency
            object&.price_currency
          end

          def shop
            nil
          end

          def is_available
            true
          end

          def is_published
            true
          end

          def is_promotional
            object.is_promotion_available
          end

          def promotion
            options[:shop_promotion]
          end

          def retailer_id
            object.retailer_id
          end

          def available_quantity
            1
          end

          def image_url
            object.image.photo_url(:medium)
          end

          def full_image_url
            object.image.photo_url(:medium)
          end

          def country
            nil
          end

          def is_proposal_product
            true
          end

        end
      end
    end
  end
end
