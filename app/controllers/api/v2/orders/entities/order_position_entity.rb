# frozen_string_literal: true

module API
  module V2
    module Orders
      module Entities
        class OrderPositionEntity < API::V1::Orders::Entities::ShowPositionEntity
          unexpose :product_shelf_life
          unexpose :product_country_alpha2
          unexpose :shop_id
          unexpose :shop_price_cents
          unexpose :shop_price_dollars
          expose :price, documentation: { type: 'Float', desc: 'Full dollars of the price' }, format_with: :float
          expose :promotional_price, documentation: { type: 'Float', desc: 'Promotional Price' }, format_with: :float
          expose :pickup_priority, documentation: { type: 'Integer', desc: 'Pickup Priority' }, format_with: :integer, :if => Proc.new { options[:retailer] }
          expose :order_substitutions, override: true, documentation: { type: 'show_product', is_array: true } do |result, options|
            API::V2::Orders::Entities::OrderSubstitutionEntity.represent order_substitutions, retailer_with_stock: options[:retailer_with_stock]
          end

          def price
            (object.shop_price_dollars + (object.shop_price_cents).to_f / 100).round(2)
          end

          def order_substitutions
            object.order_subs_view if object.status_id == 6
          end

          def substitute_for
            object.order_subs_view.select { |os| os.is_selected == true }.first&.substitute_detail.try(:[], 'product_name')
          end

        end
      end
    end
  end
end