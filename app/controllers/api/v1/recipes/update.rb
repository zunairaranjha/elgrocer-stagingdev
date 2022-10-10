module API
  module V1
    module Recipes
      class Update < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :recipes do
          desc "Allows creating a recipe. Requires authentication.", entity: API::V1::Recipes::Entities::ShowEntity
          params do
            requires :id, type: Integer, desc: "Recipe Id", documentation: { example: 2 }
            optional :name, type: String, desc: "Recipe name", documentation: { example: "Chicken" }
            optional :category_id, type: Integer, desc: "Recipe Category id", documentation: { example: 23 }
            optional :prep_time, type: Integer, desc: "Recipe Preparation", documentation: { example: 23 }
            optional :cook_time, type: Integer, desc: "Recipe Cooking time", documentation: { example: 23 }
            optional :chef_id, type: Integer, desc: "Id of chef", documentation: { example: 23 }
            optional :for_people, type: Integer, desc: "For people", documentation: { example: 2 }
            optional :description, type: String, desc: "Description of Recipe", documentation: { example: "http://example.com" }
            optional :is_published, type: Boolean, desc: "Describes if recipe is published or not", documentation: { example: false }
            optional :deep_link, type: String, desc: "Deep Link for Recipe", documentation: { example: "http://example.com" }
            optional :photo, type: Rack::Multipart::UploadedFile, desc: "Photo of Recipe"
          end
          put do
            recipe = Recipe.find_by(id: params[:id])
            object = {
              name: params[:name],
              recipe_category_id: params[:category_id],
              prep_time: params[:prep_time],
              cook_time: params[:cook_time],
              chef_id: params[:chef_id],
              for_people: params[:for_people],
              description: params[:description],
              is_published: params[:is_published],
              deep_link: params[:deep_link]
            }
            recipe.photo = ActionDispatch::Http::UploadedFile.new(params[:photo]) if params[:photo]
            recipe.update!(object.compact)
            #present recipe, with: API::V1::Recipes::Entities::ShowEntity
          end
        end
      end
    end
  end
end