# frozen_string_literal: true

module API
  module V1
    module Countries
      module Entities
        class ShowEntity < API::BaseEntity
          def self.entity_name
            'show_country'
          end

          expose :name, documentation: { type: 'String', desc: 'Country name' }, format_with: :string
          expose :alpha2, documentation: { type: 'String', desc: 'Country ISO' }, format_with: :string
        end
      end
    end
  end
end
