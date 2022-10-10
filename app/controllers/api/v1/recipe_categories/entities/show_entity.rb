module API
  module V1
    module RecipeCategories
      module Entities
        class ShowRecipeSubcategoryEntity < API::BaseEntity
          def self.entity_name
            'show_recipe_subcategory'
          end
          expose :id, documentation: { type: 'Integer', desc: "ID of the recipe_category" }, format_with: :integer
          expose :parent_id, documentation: {type: 'Integer', desc: 'Id of parent recipe_category'}
          expose :name, documentation: { type: 'String', desc: "Recipe Category name" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: "Slug of Recipe Subcategory" }, format_with: :string
          expose :description, documentation: { type: 'String', desc: "Description of chef" }, format_with: :string
        
          def image_url
            object.photo_url
          end
        end
        
        class ShowEntity < API::BaseEntity
          def self.entity_name
            'show_recipe_category'
          end
          expose :id, documentation: { type: 'Integer', desc: "ID of the recipe_category" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Recipe Category name" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "url of image" }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: "Slug of Recipe Category" }, format_with: :string
          expose :description, documentation: { type: 'String', desc: "Description of chef" }, format_with: :string
          expose :seo_data, documentation: {type: 'String', desc: "SEO Data"}, format_with: :string, if: Proc.new { |obj| options[:web] }
          # expose :recipe_subcategories, using: API::V1::RecipeCategories::Entities::ShowRecipeSubcategoryEntity, as: :subcategories, documentation: {type: 'show_recipe_subcategory', is_array: true }
          
        
          def image_url
            object.photo_url
          end
        
          def recipe_subcategories
            object.recipe_subcategories
          end
          
        end
                
      end
    end
  end
end