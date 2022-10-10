# frozen_string_literal: true

module API
  module V1
    module Retailers
      module Entities
        class PaymentTypesAndCard < API::BaseEntity
          expose :payment_types, using: API::V1::Retailers::Entities::ShowPaymentTypeEntity, documentation: {type: 'show_payment_type', is_array: true }
          expose :cards, using: API::V1::CreditCards::Entities::ShowEntity, documentation: {type: 'show_credit_card', is_array: true }
        end                
      end
    end
  end
end