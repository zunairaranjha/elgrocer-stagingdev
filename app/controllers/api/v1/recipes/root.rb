module API
  module V1
    module Recipes
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::Recipes::Index
        mount API::V1::Recipes::RecipeDetail
        mount API::V1::Recipes::Create
        mount API::V1::Recipes::CreateIngredients
        mount API::V1::Recipes::Publish
        mount API::V1::Recipes::Update
        mount API::V1::Recipes::UpdatePhoto
        mount API::V1::Recipes::UpdateIngredients
        mount API::V1::Recipes::RecipeElasticSearch
        mount API::V1::Recipes::ProductElasticSearch
      end
      
    end
  end
end