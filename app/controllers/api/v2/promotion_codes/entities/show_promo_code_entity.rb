# frozen_string_literal: true

module API
  module V2
    module PromotionCodes
      module Entities
        class ShowPromoCodeEntity < API::BaseEntity
          root 'promotion_codes'
        
          def self.entity_name
            'show_promotion_code'
          end
        
          expose :id, documentation: { type: 'Integer', desc: 'ID of the promotion code' }, format_with: :integer
          expose :value_cents, documentation: { type: 'Integer', desc: 'Value of the promotion code' }, format_with: :integer
          expose :value_currency, documentation: { type: 'String', desc: 'Currency of the promotion code' }, format_with: :string
          expose :code, documentation: { type: 'String', desc: 'Code given to user' }, format_with: :string
          expose :allowed_realizations, documentation: { type: 'Integer', desc: 'Allowed realizations of the code' }, format_with: :integer
        end        
      end
    end
  end
end