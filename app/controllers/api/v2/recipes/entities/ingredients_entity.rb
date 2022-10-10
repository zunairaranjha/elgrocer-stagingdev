# frozen_string_literal: true

module API
  module V2
    module Recipes
      module Entities
        class IngredientsEntity < API::V1::Recipes::Entities::ShowIngredientsEntity

          def self.entity_name
            'ingredients_entity'
          end

          unexpose :brand_id
          unexpose :subcategory_id
          unexpose :recipe_id
          expose :qty, override: true, documentation: { type: 'String', desc: 'Qty of ingredients' }, format_with: :string
          expose :brand, override: true, using: API::V1::Brands::Entities::BrandInProductEntity, documentation: { type: 'show_brand', is_array: true }
          expose :categories, override: true, using: API::V1::Categories::Entities::CategoryInProductEntity, documentation: { type: 'name_entity', is_array: true }
          expose :subcategories, override: true, using: API::V1::Categories::Entities::CategoryInProductEntity, documentation: { type: 'name_entity', is_array: true }

        end
      end
    end
  end
end
