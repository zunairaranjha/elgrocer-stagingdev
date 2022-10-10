# frozen_string_literal: true

module API
  module V2
    module Recipes
      module Entities
        class IndexEntity < API::V1::Recipes::Entities::IndexEntity

          def self.entity_name
            'recipe_index'
          end

          unexpose :category_id
          unexpose :recipe_category_name
          unexpose :prep_time
          unexpose :cook_time
          unexpose :for_people
          unexpose :is_published
          unexpose :deep_link
          expose :storyly_slug
          expose :is_saved, documentation: { type: 'Boolean', desc: 'Saved for Shopper or Not' }, format_with: :bool
          expose :chef, override: true, using: API::V2::Chefs::Entities::ShowEntity, documentation: { type: 'show_chef', is_array: true }

          private

          def is_saved
            !object.try(:shopper_id).blank?
          end

        end
      end
    end
  end
end
