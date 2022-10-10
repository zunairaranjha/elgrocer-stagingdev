module API
  module V1
    module Recipes
      class UpdatePhoto < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :recipes do
          desc "Allows creating a recipe. Requires authentication.", entity: API::V1::Recipes::Entities::ShowEntity
          params do
            requires :id, type: Integer, desc: 'ID of Recipe', documentation: {example: 10} 
            requires :photo, type: Rack::Multipart::UploadedFile, desc: "Photo of recipe"
          end
          put '/update_photo' do
            recipe = Recipe.find(params[:id])
            if recipe
              recipe.photo = ActionDispatch::Http::UploadedFile.new(params[:photo])
              recipe.save!
            else
              false
            end
          end
        end
      end      
    end
  end
end