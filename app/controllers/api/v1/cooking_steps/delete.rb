# frozen_string_literal: true

module API
  module V1
    module CookingSteps
      class Delete < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :cooking_steps do
          desc "Allows update or create a cooking_step. Requires authentication.", entity: API::V1::CookingSteps::Entities::ShowEntity
          params do
            requires :id, type: Integer, desc: 'ID of CookingStep', documentation: {example: 10} 
          end
          delete do
            CookingStep.delete(params[:id])
            # present chef, with: API::V1::CookingSteps::Entities::ShowEntity
          end
        end
      end      
    end
  end
end