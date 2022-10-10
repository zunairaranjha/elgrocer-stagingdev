# frozen_string_literal: true

module API
  module V1
    module CookingSteps
      class UpdatePhoto < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :cooking_steps do
          desc "Allows update or create a cooking_step. Requires authentication.", entity: API::V1::CookingSteps::Entities::ShowEntity
          params do
            optional :id, type: Integer, desc: 'ID of CookingStep', documentation: {example: 10} 
            requires :photo, type: Rack::Multipart::UploadedFile, desc: "Photo of recipe"
          end
          post 'update_photo' do
            step = CookingStep.new
            step = CookingStep.find_by(id: params[:id]) if params[:id]
            step.photo = ActionDispatch::Http::UploadedFile.new(params[:photo])
            if step.save!
              step.id
            else
              false
            end
            # present chef, with: API::V1::CookingSteps::Entities::ShowEntity
          end
        end
      end      
    end
  end
end