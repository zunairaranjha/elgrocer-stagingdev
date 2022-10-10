module API
  module V1
    module Recipes
      class RecipeDetail < Grape::API
        # include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :recipes do
          desc "Return recipe.", entity: API::V1::Recipes::Entities::ShowEntity
          params do
            requires :id, desc: "Id of Recipe", documentation: { example: 1 }
            optional :retailer_id, type: Integer, desc: "Id of Retailer", documentation: { example: 16 }
          end
          get '/recipe_detail' do
            recipe = params[:id][/\p{L}/] ? Recipe.where(slug: params[:id]) : Recipe.where(id: params[:id])
            # id = params[:id].to_i > 0 ? params[:id].to_i : (params[:id] ? Recipe.find(params[:id]) : params[:id])
            # recipe = Recipe.where(id: id)
            recipe = recipe.includes(:cooking_steps,:chef).order('cooking_steps.step_number') #if recipe.length > 0
            present recipe, with: API::V1::Recipes::Entities::ShowEntity, retailer_id: params[:retailer_id], web:  request.headers['Referer']
          end
        end
      end
    end
  end
end