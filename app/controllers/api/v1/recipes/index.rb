module API
  module V1
    module Recipes
      class Index < Grape::API
        # include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :recipes do
          desc "Return recipe.", entity: API::V1::Recipes::Entities::IndexEntity
          params do
            optional :limit, type: Integer, desc: "Limit", documentation: { example: 10 }
            optional :offset, type: Integer, desc: "offset", documentation: { example: 23 }
            optional :id, desc: "Id of Recipe", documentation: { example: 1 }
            optional :category_id, desc: 'Id of Recipe Category', documentation: { example: 2 }
            optional :subcategory_id, desc: 'Id of Recipe Subcategory', documentation: { example: 2 }
            optional :chef_id, desc: "Chef Id of Recipe", documentation: { example: 1 }
          end
          get do
            id = params[:id].to_i > 0 ? params[:id].to_i : (params[:id] ? Recipe.select(:id).find_by(slug: params[:id]) : params[:id])
            chef_id = params[:chef_id].to_i > 0 ? params[:chef_id].to_i : (params[:chef_id] ? Chef.select(:id).find_by(slug: params[:chef_id]) : params[:chef_id])
            category_id = params[:category_id].to_i > 0 ? params[:category_id].to_i : (params[:category_id] ? RecipeCategory.select(:id).find_by(slug: params[:category_id]) : params[:category_id])
            object = {
              id: id,
              chef_id: chef_id,
              # recipe_category_id: params[:subcategory_id],
              recipe_category_id: category_id
            }
            # if params[:category_id]
            #   recipe_category = RecipeCategory.where(parent_id: params[:category_id])
            #   object[:recipe_category_id] = recipe_category
            # end
            object = object.compact
            result = Rails.cache.fetch([params, __method__], expires_in: 15.minutes) do
              result = Recipe.where(is_published: true).order(id: :desc).limit(params[:limit]).offset(params[:offset])
              result = result.where(object) if object.any?
              result = result.includes(:chef, :recipe_categories)
              result.to_a
            end
            present result, with: API::V1::Recipes::Entities::IndexEntity, web: request.headers['Referer']
          end
        end
      end
    end
  end
end