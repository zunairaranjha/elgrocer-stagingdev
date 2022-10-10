module API
  module V1
    module Recipes
      class UpdateIngredients < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :recipes do
          desc "Allows creating a recipe. Requires authentication.", entity: API::V1::Recipes::Entities::ShowEntity
          params do
            requires :recipe_id, type: Integer, desc: "REcipe ID", documentation: { example: 2 }
            requires :ingredients, type: Array do
              requires :product_id, type: Integer, desc: "Desired product_id", documentation: { example: 5 }
              requires :qty, type: Float, desc: "Desired amount of product", documentation: { example: 5 }
              requires :qty_unit, type: String, desc: "Unit of amount of product", documentation: { example: "gram" }
            end
          end
          put '/update_ingredients' do
            recipe = Recipe.select(:id).find_by(id: params[:recipe_id])
            ingredients = params[:ingredients]
            new_ingredients = []
            ingredients.each do |ingredient|
              new_ingredient = Ingredient.new(product_id: ingredient[:product_id], qty: ingredient[:qty], qty_unit: ingredient[:qty_unit], recipe_id: recipe.id)
              new_ingredients.push(new_ingredient)
            end
            if recipe.ingredients = new_ingredients
              true
            else
              false
            end
            # present recipe, with: API::V1::Recipes::Entities::ShowEntity
          end
        end
      end
    end
  end
end