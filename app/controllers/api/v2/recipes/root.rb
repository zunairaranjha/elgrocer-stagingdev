module API
  module V2
    module Recipes
      class Root < Grape::API
        version 'v2', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V2::Recipes::Index
        mount API::V2::Recipes::RecipeDetail

      end
    end
  end
end
