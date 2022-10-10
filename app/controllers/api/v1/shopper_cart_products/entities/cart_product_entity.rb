# frozen_string_literal: true

module API
  module V1
    module ShopperCartProducts
      module Entities
        class CartProductEntity < API::V2::Products::Entities::ListEntity

          expose :retailer_id, override: true, documentation: { type: 'String', desc: 'Product retailer id' }
          expose :price, override: true, as: :full_price, documentation: { type: 'Float', desc: 'Price of product' }, format_with: :float
          expose :price_currency, override: true, documentation: { type: 'String', desc: 'Price Currency' }, format_with: :string
          expose :is_available, override: true, documentation: { type: 'Boolean', desc: 'Is product disbale in shop?' }, format_with: :bool
          expose :is_published, override: true, documentation: { type: 'Boolean', desc: 'Is product published in shop?' }, format_with: :bool
          expose :is_promotional, override: true, as: :is_p, documentation: { type: 'Boolean', desc: 'Is product promotional in shop?' }, format_with: :bool
          expose :messages, documentation: { type: 'show_messages', is_array: true }
          expose :available_quantity, documentation: { type: 'Integer', desc: 'Available Quantity' }, format_with: :integer

          private

          def retailer_id
            options[:retailer_id]
          end

          def shop
            options[:shop]
          end

          def price
            if promotion.present?
              promotion.standard_price
            else
              (shop&.price_dollars.to_i + shop&.price_cents.to_i / 100.0).round(2)
            end
          end

          def price_currency
            shop&.price_currency || promotion&.price_currency || 'AED'
          end

          def subcategory_id
            object.subcategories.first.try(:id)
          end

          def is_available
            available_quantity.negative? ? availability : (availability && available_quantity.positive? || reserved_quantity[object.id.to_s].to_i.positive?)
          end

          def availability
            shop&.promotion_only? ? promotion.present? : shop&.is_available
          end

          def is_published
            shop&.promotion_only? ? promotion.present? : shop&.is_published
          end

          def is_promotional
            shop&.promotion_only
          end

          def messages
            options[:messages]
          end

          def available_quantity
            retailer_with_stock ? (shop&.available_for_sale.to_i + reserved_quantity[object.id.to_s].to_i) : -1
          end

          def retailer_with_stock
            options[:retailer_with_stock]
          end

          def reserved_quantity
            options[:reserved_quantity] || {}
          end
        end
      end
    end
  end
end
