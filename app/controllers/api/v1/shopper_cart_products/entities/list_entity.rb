# frozen_string_literal: true

module API
  module V1
    module ShopperCartProducts
      module Entities
        class ListEntity < API::V1::ShopperCartProducts::Entities::ShowEntity
          unexpose :created_at
          unexpose :product
          expose :product do |result, options|
            API::V1::ShopperCartProducts::Entities::CartProductEntity.represent object.product, options.merge(
              retailer_id: object.retailer_id, shop: object.shop, messages: messages, retailer_with_stock: cart_retailer&.with_stock_level)
          end

          private

          def messages
            messages = []
            unless object.shop_promotion_id == current_promotion&.id
              messages.push({ message_code: 2000, message: I18n.t('message.message_2000') })
            end
            if (current_promotion.present? && current_promotion.product_limit.to_i.positive? && object.quantity > current_promotion.product_limit) ||
               (cart_retailer&.with_stock_level && (object.shop&.available_for_sale.to_i + reserved_quantity[object.product_id.to_s].to_i) < object.quantity)
              messages.push({ message_code: 2001, message: I18n.t('message.message_2001') })
            end
            messages
          end

          def current_promotion
            @current_promotion ||= object.current_promotions.first
          end

          def cart_retailer
            options[:cart_retailer]
          end

          def reserved_quantity
            options[:reserved_quantity] || {}
          end
        end
      end
    end
  end
end
