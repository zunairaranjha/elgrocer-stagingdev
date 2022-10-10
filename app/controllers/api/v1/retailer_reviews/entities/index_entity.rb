# frozen_string_literal: true

module API
  module V1
    module RetailerReviews
      module Entities
        class IndexEntity < API::BaseEntity
          expose :reviews, using: API::V1::RetailerReviews::Entities::ShowEntity, documentation: {type: 'show_review', is_array: true }
          expose :is_next, documentation: { type: 'Boolean', desc: "Is something else in list of categories?" }, format_with: :bool
        end                
      end
    end
  end
end