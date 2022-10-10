module API
  module V1
    module Recipes
      class RecipeElasticSearch < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :recipes do
          desc "Find product by provided input. Requires authentication.", entity: API::V1::Products::Entities::ElasticSearchEntity
          params do
            requires :search_input, type: String, desc: 'Search input', documentation: { example: 'CocaCola' }
            requires :page, type: Integer, desc: "Page number", documentation: { example: 2 }
            optional :chef_id, type: Integer, desc: "Chef Id", documentation: { example:2 }
            optional :subcategory_id, type: Integer, desc: "Subcategory Id", documentation: { example:2 }
            optional :category_id, type: Integer, desc: "Category Id", documentation: { example:2 }
          end
      
          post '/recipe_elastic_search' do
            error!({ error_code: 10_422, error_message: 'Please update to latest version' }, 422)
            #query = {
            #      bool: {
            #        must: [
            #          { multi_match: {
            #              query: params[:search_input],
            #              slop: 50,
            #              type: "most_fields",
            #              minimum_should_match: "70%",
            #              fields: ["*name*"],
            #              operator: "and"
            #            }
            #          }
            #        ]
            #      }
            #    }
            #query[:bool][:must].push({term: {'chef.id': params[:chef_id]}}) if params[:chef_id]
            #query[:bool][:must].push({term: {'category_id': params[:category_id]}}) if params[:category_id]
            #query[:bool][:must].push({term: {'subcategory_id': params[:subcategory_id]}}) if params[:subcategory_id]
            #result = Recipe.search(query).page(params[:page])
            #present result
          end
        end
      end
    end
  end
end