# frozen_string_literal: true

module API
  module V1
    module Products
      module Entities
        class BarcodeSearchEntity < API::V1::Products::Entities::ShowEntity

          def shop
            options[:shop]
          end

          def price
            {
              price_cents: shop&.price_cents,
              price_dollars: shop&.price_dollars,
              price_currency: shop&.price_currency
            }
          end

        end
      end
    end
  end
end
