# frozen_string_literal: true

module API
  module V2
    module Recipes
      module Entities
        class CategoryEntity < API::BaseEntity

          def self.entity_name
            'recipe_category_entities'
          end

          expose :id, documentation: { type: 'Integer', desc: 'Id of the Category' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Name of the Category' }, format_with: :string

        end
      end
    end
  end
end
