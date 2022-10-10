# frozen_string_literal: true

module API
  module V2
    module ShopperCartProducts
      class Root < Grape::API
        version 'v2', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V2::ShopperCartProducts::Index
        mount API::V2::ShopperCartProducts::Create
        mount API::V2::ShopperCartProducts::BulkCreate
      end
    end
  end
end
