module API
  module V1
    module Recipes
      module Entities
        class IndexEntity < API::BaseEntity
          def self.entity_name
            'recipe_index'
          end

          expose :id, documentation: { type: 'Integer', desc: "ID of the recipe" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "name of recipe chef" }, format_with: :string
          expose :category_id, documentation: { type: 'Integer', desc: "RecipeCategory ID" }, format_with: :integer
          expose :recipe_category_name, documentation: { type: 'String', desc: "Recipe Name" }, as: :category_name, format_with: :string
          expose :prep_time, documentation: { type: 'Integer', desc: "Preparation Time" }, format_with: :integer
          expose :cook_time, documentation: { type: 'Integer', desc: "Cooking Time" }, format_with: :integer
          expose :description, documentation: { type: 'String', desc: "Description of Recipe" }, format_with: :string
          # expose :chef_id, documentation: { type: 'Integer', desc: "Chef Id" }, format_with: :integer
          expose :for_people, documentation: { type: 'Integer', desc: "For People" }, format_with: :integer
          expose :is_published, documentation: { type: 'Boolean', desc: "Recipe Is Published" }, format_with: :bool
          expose :image_url, documentation: { type: 'String', desc: "url of image" }, format_with: :string
          expose :deep_link, documentation: { type: 'String', desc: "Deep link of recipe" }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: "Slug of Recipe" }, format_with: :string
          expose :seo_data, documentation: { type: 'String', desc: "SEO Data" }, format_with: :string, if: Proc.new { |obj| options[:web] }
          expose :chef, using: API::V1::Chefs::Entities::ShowEntity, documentation: { type: 'show_chef', is_array: true }
          # expose :ingredients, using: API::V1::Recipes::Entities::ShowIngredientsEntity, documentation: {type: 'show_ingredients', is_array: true }

          def image_url
            object.photo_url
          end

          def recipe_category_name
            object.recipe_categories.first&.name
          end

          def category_id
            object.recipe_categories.first&.id
          end
        end
      end
    end
  end
end