module API
  module V1
    module Recipes
      class Publish < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :recipes do
          desc "Publish and un publish recipe. Requires authentication.", entity: API::V1::Recipes::Entities::ShowEntity
          params do
            requires :id, type: Integer, desc: "Id of Recipe", documentation: { example: 1 }
            requires :is_published, type: Boolean, desc: "offset", documentation: { example: 23 }
          end
          put '/publish' do
            recipe = Recipe.find(params[:id])
            recipe.is_published = params[:is_published]
            recipe.save!
          end
        end
      end
      
    end
  end
end