# frozen_string_literal: true

module API
  module V1
    module Products
      module Entities
        class ShowPriceEntity < API::BaseEntity
          def self.entity_name
            'show_price'
          end

          expose :price_cents, documentation: { type: 'Integer', desc: 'Cents of the price' }, format_with: :integer
          expose :price_currency, documentation: { type: 'String', desc: 'Currency' }, format_with: :string
          expose :price_dollars, documentation: { type: 'Integer', desc: 'Full dollars of the price' }, format_with: :integer
          expose :price_full, documentation: { type: 'Float', desc: 'Full dollars of the price' }, format_with: :float

          private

          def price_full
            (object[:price_dollars].to_i + (object[:price_cents].to_f / 100)).round(2)
          end

        end
      end
    end
  end
end
