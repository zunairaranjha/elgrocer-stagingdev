# frozen_string_literal: true

module API
  module V1
    module CookingSteps
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :cooking_steps do
          desc "Allows creating cooking_steps. Requires authentication.", entity: API::V1::CookingSteps::Entities::ShowEntity
          params do
            requires :recipe_id, type: Integer, desc: "Recipe Id", documentation: { example: 5}
            requires :cooking_steps, type: Array do
              optional :id, type: Integer, desc: "CookingStep Id", documentation: { example: 5}
              optional :time, type: Integer, desc: "Time of cooking step", documentation: { example: 30 }
              requires :step_number, type: Integer, desc: "CookingStep Number", documentation: { example: 5}
              requires :step_detail, type: String, desc: "CookingStep Detail", documentation: { example: "Poor Some Food"}
            end
          end
          post do
            recipe = Recipe.find_by(id: params[:recipe_id])
            steps = params[:cooking_steps]
            result = []
            steps.each do |step|
              cooking_step = CookingStep.new
              cooking_step = CookingStep.find_by(id: step[:id]) if step[:id]
              cooking_step.recipe_id = recipe.id
              cooking_step.step_number = step[:step_number]
              cooking_step.step_detail = step[:step_detail] 
              cooking_step.time = step[:time]
              cooking_step.save!
              result.push(cooking_step)
            end
            present result, with: API::V1::CookingSteps::Entities::ShowEntity
          end
        end
      end      
    end
  end
end