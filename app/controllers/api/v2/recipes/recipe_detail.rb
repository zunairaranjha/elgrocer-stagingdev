module API
  module V2
    module Recipes
      class RecipeDetail < Grape::API
        version 'v2', using: :path
        format :json

        resource :recipes do
          desc 'Get Detail of the recipe'

          params do
            requires :id, desc: 'Id of the recipe', documentation: { example: 3 }
            optional :retailer_id, type: Integer, desc: 'Id of the retailer', documentation: { example: 16 }
            optional :shopper_id, type: Integer, desc: 'Id of the shopper', documentation: { example: 35099 }
          end

          get '/recipe_detail' do
            recipe = params[:id][/\p{L}/] ? Recipe.where(slug: params[:id]) : Recipe.where(id: params[:id])
            recipe = recipe.where(is_published: true)
            if params[:retailer_id]
              store_type_ids = RetailerStoreType.distinct.where("retailer_id in (#{params[:retailer_id]})").pluck(:store_type_id).join(',')
              retailer_group_ids = Retailer.distinct.where("id in (#{params[:retailer_id]})").where.not(retailer_group_id: nil).pluck(:retailer_group_id).join(',')
              recipe = recipe.where.not("'{#{params[:retailer_id]}}'::INT[] && exclude_retailer_ids")
              recipe = recipe.where("'{#{params[:retailer_id]}}'::INT[] && retailer_ids OR '{#{store_type_ids}}'::INT[] && store_type_ids OR '{#{retailer_group_ids}}'::INT[] && retailer_group_ids")
            end
            if params[:shopper_id]
              recipe = recipe.joins("LEFT JOIN shopper_recipes ON shopper_recipes.recipe_id = recipes.id AND shopper_recipes.shopper_id = #{params[:shopper_id]}")
              recipe = recipe.select("recipes.*, shopper_recipes.shopper_id AS shopper_id").group(:id, :shopper_id)
            end
            error!(CustomErrors.instance.recipe_not_found, 421) unless recipe.first

            present recipe.first, with: API::V2::Recipes::Entities::ShowEntity, retailer_id: params[:retailer_id], web: request.headers['Referer']
          end
        end
      end
    end
  end
end

