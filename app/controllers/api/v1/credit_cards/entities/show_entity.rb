# frozen_string_literal: true

module API
  module V1
    module CreditCards
      module Entities
        class ShowEntity < API::BaseEntity
          root 'credit_cards', 'credit_card'

          def self.entity_name
            'show_credit_card'
          end

          expose :id, documentation: { type: 'Integer', desc: 'Credit Card id' }, format_with: :integer
          expose :card_type_value, as: :card_type, documentation: { type: 'String', desc: 'Credit Card Type (e.g Visa)' }, format_with: :string
          expose :last4, documentation: { type: 'String', desc: 'Credit Card Last 4 Digits (e.g 4444)' }, format_with: :string
          expose :country, documentation: { type: 'String', desc: 'Card Country (e.g. UAE)' }, format_with: :string
          expose :first6, documentation: { type: 'String', desc: 'Credit Card First 6 Digits (e.g 343434)' }, format_with: :string
          expose :expiry_month, documentation: { type: 'Integer', desc: 'Credit Card Expiry Month (e.g 12)' }, format_with: :integer
          expose :expiry_year, documentation: { type: 'Integer', desc: 'Credit Card Expiry Year (e.g 12)' }, format_with: :integer
          expose :trans_ref, documentation: { type: 'String', desc: 'Transaction Reference Number (e.g 030017131622)' }, format_with: :string
          expose :cvv, documentation: { type: 'String', desc: 'Card Security Number' }, format_with: :integer

          def card_type_value
            object.card_type.to_i % 1000
          end

        end
      end
    end
  end
end
