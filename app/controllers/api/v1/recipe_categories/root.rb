# frozen_string_literal: true

module API
  module V1
    module RecipeCategories
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::RecipeCategories::Index
      end
      
    end
  end
end