# frozen_string_literal: true

module API
  module V2
    module Recipes
      class Index < Grape::API
        version 'v2', using: :path
        format :json

        resource :recipes do
          desc 'To get the list of recipes'

          params do
            requires :retailer_ids, type: String, desc: 'Comma Separated retailer ids', documentation: { example: '16,178' }
            optional :limit, type: Integer, desc: 'Limit', documentation: { example: 10 }
            optional :offset, type: Integer, desc: 'offset', documentation: { example: 23 }
            optional :id, desc: 'Id of Recipe', documentation: { example: 1 }
            optional :category_id, desc: 'Id of Recipe Category', documentation: { example: 2 }
            optional :chef_id, desc: 'Chef Id of Recipe', documentation: { example: 1 }
            optional :shopper_id, type: Integer, desc: 'Id of the Shopper', documentation: { example: 35099 }
          end

          get do
            error!(CustomErrors.instance.params_missing, 421) unless params[:retailer_ids].present?
            store_type_ids = RetailerStoreType.distinct.where("retailer_id in (#{params[:retailer_ids]})").pluck(:store_type_id).join(',')
            retailer_group_ids = Retailer.distinct.where("id in (#{params[:retailer_ids]})").where.not(retailer_group_id: nil).pluck(:retailer_group_id).join(',')
            recipes = Recipe.where(is_published: true).limit(params[:limit]).offset(params[:offset])
            recipes = recipes.where.not("'{#{params[:retailer_ids]}}'::INT[] && exclude_retailer_ids") unless params[:retailer_ids].split(',').length > 1
            recipes = recipes.where(id: (params[:id][/\p{L}/] ? Recipe.select(:id).find_by(slug: params[:id]) : params[:id].to_i)) if params[:id]
            recipes = recipes.where(chef_id: (params[:chef_id][/\p{L}/] ? Chef.select(:id).find_by(slug: params[:chef_id]) : params[:chef_id].to_i)) if params[:chef_id]
            recipes = recipes.joins(:recipes_categories).where(recipes_categories: { recipe_category_id: (params[:category_id][/\p{L}/] ? RecipeCategory.select(:id).find_by(slug: params[:category_id]) : params[:category_id].to_i) }) if params[:category_id]
            recipes = recipes.where("'{#{params[:retailer_ids]}}'::INT[] && retailer_ids OR '{#{store_type_ids}}'::INT[] && store_type_ids OR '{#{retailer_group_ids}}'::INT[] && retailer_group_ids")
            recipes = recipes.order(:priority, :created_at)
            recipes = recipes.includes(:chef)
            if params[:shopper_id]
              recipes = recipes.joins("LEFT JOIN shopper_recipes ON shopper_recipes.recipe_id = recipes.id AND shopper_recipes.shopper_id = #{params[:shopper_id]}")
              recipes = recipes.select('recipes.*, shopper_recipes.shopper_id AS shopper_id').group(:id, :shopper_id)
            end

            present recipes, with: API::V2::Recipes::Entities::IndexEntity, web: request.headers['Referer']
          end
        end
      end
    end
  end
end

