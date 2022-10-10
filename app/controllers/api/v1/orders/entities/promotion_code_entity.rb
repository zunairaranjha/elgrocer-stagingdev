module API
  module V1
    module Orders
      module Entities
        class PromotionCodeEntity < API::BaseEntity
          root 'promotion_codes', 'promotion_code'

          def self.entity_name
            'show_promotion_code'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the promotion code' }, format_with: :integer
          expose :value_cents, documentation: { type: 'Integer', desc: 'Value of the promotion code' }, format_with: :integer
          expose :value_currency, documentation: { type: 'String', desc: 'Currency of the promotion code' }, format_with: :string
          expose :code, documentation: { type: 'String', desc: 'Code given to user' }, format_with: :string

          private

          def value_cents
            options[:discount_value].to_i > 0 ? options[:discount_value] : object.value_cents
          end
        end
      end
    end
  end
end