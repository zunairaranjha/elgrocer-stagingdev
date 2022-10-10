module API
  module V1
    module ShopperRecipes
      class Show < Grape::API
        version 'v1', using: :path
        format :json

        resource :shopper_recipes do
          desc "Show Saved Recipes!"

          params do
            requires :shopper_id, type: Integer, desc: 'Shopper id', documentation: { example: 3 }
            optional :category_id, type: Integer, desc: 'Category id', documentation: { example: 6 }
          end

          get '/show' do
            shopper_recipes = Recipe.where(is_published: true).joins(:shopper_recipes).includes(:chef)
            shopper_recipes = shopper_recipes.where(shopper_recipes: { shopper_id: params[:shopper_id] })
            shopper_recipes = shopper_recipes.select("recipes.*, shopper_recipes.shopper_id AS shopper_id").group(:id, :shopper_id)
            shopper_recipes = shopper_recipes.joins("INNER JOIN recipes_categories ON recipes.id = recipes_categories.recipe_id AND recipes_categories.recipe_category_id = #{params[:category_id]} ") if params[:category_id]
            present shopper_recipes, with: API::V2::Recipes::Entities::IndexEntity, web: request.headers['Referer']
          end
        end
      end
    end
  end
end