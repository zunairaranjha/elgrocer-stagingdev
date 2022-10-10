# frozen_string_literal: true

module API
  module V1
    module ShopperCartProducts
      module Entities
        class ShowEntity < API::BaseEntity
          root 'shopper_cart_products', 'shopper_cart_product'

          def self.entity_name
            'show_cart_product'
          end

          expose :id, documentation: { type: 'Integer', desc: 'Cart Product id' }, format_with: :integer
          # expose :retailer_id, documentation: {type: 'Integer', desc: 'Retailer id'}, format_with: :integer
          # expose :product_id, documentation: {type: 'Integer', desc: 'Product id'}, format_with: :integer
          expose :quantity, documentation: { type: 'Integer', desc: 'Quantity' }, format_with: :integer
          expose :created_at, documentation: { type: 'String', desc: 'Cart Product flat number' }, format_with: :string
          expose :updated_at, documentation: { type: 'String', desc: 'Cart Product flat number' }, format_with: :string
          # expose :product, using: API::V1::Products::Entities::ShowEntity
          # expose :product do |item,options|
          #   API::V1::Products::Entities::ShowEntity.represent item.product, options.merge(retailer: item.retailer)
          # end
          # expose :method_name, documentation: {is_array: true}
          # expose :product, using: API::V1::ShopperCartProducts::Entities::ShowProductEntity do |item,options|
          #   options.merge(retailer_id: item.retailer_id)
          #   item.product
          # end
          expose :product do |result, options|
            API::V1::ShopperCartProducts::Entities::ShowProductEntity.represent object.product, options.merge(retailer_id: object.retailer_id, shop: object.shop, shop_promotion: object.current_promotions.first)
          end

          private

          # def method_name
          #   self.options[:env]["rack.request.query_hash"]
          # end

          # def product
          #   # result = {products: result.map{|scp| {retailer_id: params[:retailer_id], product: scp.product}}}
          #   # {retailer_id: object.retailer_id, product: object.product}
          #   object.product
          # end

          # def retailer_id
          #   object.retailer_id
          # end

        end
      end
    end
  end
end
