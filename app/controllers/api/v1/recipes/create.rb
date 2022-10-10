module API
  module V1
    module Recipes
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :recipes do
          desc "Allows creating a recipe. Requires authentication.", entity: API::V1::Recipes::Entities::ShowEntity
          params do
            requires :name, type: String, desc: "Recipe name", documentation: { example: "Chicken" }
            requires :category_id, type: Integer, desc: "Recipe Category id", documentation: { example: 23 }
            requires :prep_time, type: Integer, desc: "Recipe Preparation", documentation: { example: 23 }
            requires :cook_time, type: Integer, desc: "Recipe Cooking time", documentation: { example: 23 }
            requires :chef_id, type: Integer, desc: "Id of chef", documentation: { example: 23 }
            requires :for_people, type: Integer, desc: "For people", documentation: { example: 2 }
            optional :deep_link, type: String, desc: "Deep Link for Recipe", documentation: { example: "http://example.com" }
            optional :ingredients, type: Array do
              requires :product_id, type: Integer, desc: "Desired product_id", documentation: { example: 5}
              requires :qty, type: Integer, desc: "Desired amount of product", documentation: { example: 5}
              requires :qty_unit, type: String, desc: "Unit of amount of product", documentation: { example: "gram"}
            end
            optional :description, type: String, desc: "Description of Recipe", documentation: { example: "http://example.com" }
            optional :is_published, type: Boolean, desc: "Describes if recipe is published or not", documentation: { example: false}
            optional :photo, type: Rack::Multipart::UploadedFile, desc: "Photo of Recipe"
          end
          post do
            recipe = Recipe.new(name: params[:name], recipe_category_id: params[:category_id], prep_time: params[:prep_time], cook_time: params[:cook_time],
              chef_id: params[:chef_id], is_published: false, for_people: params[:for_people], description: params[:description], deep_link: params[:deep_link])
            recipe.photo = ActionDispatch::Http::UploadedFile.new(params[:photo]) if params[:photo]
            # recipe.description = params[:description] if params[:description]
            recipe.is_published = params[:is_published] if params[:is_published]
            recipe.save!
            if params[:ingredients].present?
              ingredients = params[:ingredients]
              new_ingredients = []
              ingredients.each do |ingredient|
                new_ingredient = {
                  product_id: ingredient[:product_id],
                  qty: ingredient[:qty],
                  qty_unit: ingredient[:qty_unit],
                  recipe_id: recipe.id
                }
                new_ingredients.push(new_ingredient)
              end
              Ingredient.transaction do
                Ingredient.create(new_ingredients)
              end
            end
            recipe.id
            #present recipe, with: API::V1::Recipes::Entities::ShowEntity
          end
        end
      end
    end
  end
end