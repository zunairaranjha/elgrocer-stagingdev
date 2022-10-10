# frozen_string_literal: true

module API
  module V1
    module Retailers
      module Entities
        class ShowPaymentTypeEntity < API::BaseEntity
          def self.entity_name
            'show_payment_type'
          end
          expose :id, documentation: { type: 'Integer', desc: "Payment Type ID"}, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Payment Type name" }, format_with: :string
        end                
      end
    end
  end
end