# frozen_string_literal: true

module API
  module V2
    module Products
      class Root < Grape::API
        version 'v2', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V2::Products::List
        mount API::V2::Products::CategoryBrand
        mount API::V2::Products::CarouselProducts
        mount API::V2::Products::PreviouslyPurchased
      end
    end
  end
end
