module API
  module V1
    module ShopperRecipes
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'

        format :json

        rescue_from :all, backtrace: true

        mount API::V1::ShopperRecipes::SaveRecipe
        mount API::V1::ShopperRecipes::Show
      end
    end
  end
end

