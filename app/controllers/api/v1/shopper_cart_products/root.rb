# frozen_string_literal: true

module API
  module V1
    module ShopperCartProducts
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V1::ShopperCartProducts::Index
        mount API::V1::ShopperCartProducts::Create
        # mount API::V1::ShopperCartProducts::Update
        mount API::V1::ShopperCartProducts::Delete
        mount API::V1::ShopperCartProducts::BulkCreate
      end
    end
  end
end
