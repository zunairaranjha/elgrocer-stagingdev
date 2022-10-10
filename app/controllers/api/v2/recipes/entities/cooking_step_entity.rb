# frozen_string_literal: true

module API
  module V2
    module Recipes
      module Entities
        class CookingStepEntity < API::V1::CookingSteps::Entities::ShowEntity

          unexpose :recipe_id
          unexpose :time
          unexpose :image_url
        end
      end
    end
  end
end
