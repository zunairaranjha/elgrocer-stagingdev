# frozen_string_literal: true

module API
  module V1
    module Orders
      module Entities
        class SubstitutionPreferenceEntity < API::BaseEntity

          expose :key, documentation: { type: 'Integer', desc: 'Key of the Substitution Preference' }, format_with: :integer
          expose :value, documentation: { type: 'String', desc: 'Substitution Preference text' }, format_with: :string

          def key
            object[0]
          end

          def value
            object[1][I18n.locale.to_s]
          end
        end
      end
    end
  end
end
