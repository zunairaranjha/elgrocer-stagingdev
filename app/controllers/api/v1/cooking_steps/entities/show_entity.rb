# frozen_string_literal: true

module API
  module V1
    module CookingSteps
      module Entities
        class ShowEntity < API::BaseEntity
          def self.entity_name
            'show_cooking_steps'
          end
          expose :id, documentation: { type: 'Integer', desc: "ID of the cooking_step" }, format_with: :integer
          expose :recipe_id, documentation: { type: 'Integer', desc: "RecipeCategory ID" }, format_with: :integer
          expose :step_number, documentation: { type: 'Integer', desc: "Step number" }, format_with: :integer
          expose :step_detail, documentation: { type: 'String', desc: "Step detail" }, format_with: :string
          expose :time, documentation: { type: 'String', desc: "Step detail" }, format_with: :integer
          expose :image_url, documentation: { type: 'String', desc: "Image url" }, format_with: :string
            
          def image_url
            object.photo_url
          end
        end                
      end
    end
  end
end