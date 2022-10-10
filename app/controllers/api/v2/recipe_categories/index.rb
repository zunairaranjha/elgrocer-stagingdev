# frozen_string_literal: true

module API
  module V2
    module RecipeCategories
      class Index < Grape::API
        version 'v2', using: :path
        format :json

        resource :recipe_categories do
          desc "Retuen the RecipeCategories"

          params do
            optional :retailer_ids, type: String, desc: 'List of retailer ids', documentation: { example: '16,178' }
            optional :limit, type: Integer, desc: "limit of RecipeCategories", documentation: { example: 10 }
            optional :offset, type: Integer, desc: "Offset of RecipeCategories", documentation: { example: 0 }
            optional :id, desc: "ID of RecipeCategory", documentation: { example: 1 }
            optional :shopper_id, type: Integer, desc: 'Id of the shopper to get filtered categories', documentation: { example: 35099 }
            optional :chef_id, type: Integer, desc: 'Chef id', documentation: { example: 1 }
          end

          get do
            error!(CustomErrors.instance.params_missing, 421) unless params[:retailer_ids].present? || params[:shopper_id]
            categories = RecipeCategory.distinct.joins(:recipes).where(recipes: { is_published: true })
            if params[:shopper_id]
              categories = categories.joins("INNER JOIN shopper_recipes ON recipes.id  = shopper_recipes.recipe_id AND shopper_recipes.shopper_id = #{params[:shopper_id]}")
            else
              store_type_ids = RetailerStoreType.distinct.where("retailer_id in (#{params[:retailer_ids]})").pluck(:store_type_id).join(',')
              retailer_group_ids = Retailer.distinct.where("id in (#{params[:retailer_ids]})").where.not(retailer_group_id: nil).pluck(:retailer_group_id).join(',')
              categories = categories.limit(params[:limit]).offset(params[:offset])
              categories = categories.where.not("'{#{params[:retailer_ids]}}'::INT[] && recipes.exclude_retailer_ids") unless params[:retailer_ids].split(',').length > 1
              categories = categories.where("'{#{params[:retailer_ids]}}'::INT[] && recipes.retailer_ids OR '{#{store_type_ids}}'::INT[] && recipes.store_type_ids OR '{#{retailer_group_ids}}'::INT[] && recipes.retailer_group_ids")
            end
            categories = categories.where(id: params[:id]) if params[:id]
            categories = categories.where(recipes: { chef_id: params[:chef_id] }) if params[:chef_id]
            data = API::V1::RecipeCategories::Entities::ShowEntity.represent(categories, except: [:description], web: request.headers['Referer'])
            data.as_json
          end
        end
      end
    end
  end
end
