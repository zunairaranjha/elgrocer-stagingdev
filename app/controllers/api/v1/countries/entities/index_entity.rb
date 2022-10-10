# frozen_string_literal: true

module API
  module V1
    module Countries
      module Entities
        class IndexEntity < API::BaseEntity
          expose :countries, using: API::V1::Countries::Entities::ShowEntity, documentation: {type: 'show_country', is_array: true }
        end                
      end
    end
  end
end