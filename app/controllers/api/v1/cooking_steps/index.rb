# frozen_string_literal: true

module API
  module V1
    module CookingSteps
      class Index < Grape::API
        # include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :cooking_steps do
          desc "Allows creating cooking_steps. Requires authentication.", entity: API::V1::CookingSteps::Entities::ShowEntity
          params do
            requires :recipe_id, type: Integer, desc: "Recipe Id", documentation: { example: 5}
          end
          get do
            cooking_step = CookingStep.where(recipe_id: params[:recipe_id]).order(:step_number)
            present cooking_step, with: API::V1::CookingSteps::Entities::ShowEntity
          end
        end
      end      
    end
  end
end