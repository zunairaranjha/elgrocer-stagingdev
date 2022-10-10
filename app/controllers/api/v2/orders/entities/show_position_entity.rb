# frozen_string_literal: true

module API
  module V2
    module Orders
      module Entities
        class ShowPositionEntity < API::V1::Orders::Entities::ShowPositionEntity
          unexpose :product_shelf_life
          unexpose :product_country_alpha2
          unexpose :shop_id
          unexpose :shop_price_cents
          unexpose :shop_price_dollars
          expose :price, documentation: { type: 'Float', desc: "Full dollars of the price" }, format_with: :float
          expose :promotional_price, documentation: { type: 'Float', desc: 'Promotional Price' }, format_with: :float
          expose :order_substitutions, override: true, documentation: {type: 'show_product', is_array: true } do |result, options|
            API::V2::Orders::Entities::ShowSubstitutionProduct.represent order_substitutions, options.merge(retailer_id: object.order.retailer_id)
          end

          def price
            (object.shop_price_dollars + (object.shop_price_cents).to_f/100).round(2)
          end
        end
      end
    end
  end
end