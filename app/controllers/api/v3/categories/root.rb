# frozen_string_literal: true

module API
  module V3
    module Categories
      class Root < Grape::API
        version 'v3', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        # mount API::V2::Categories::ShopperCategories
        # mount API::V2::Categories::CategoryProducts
        mount API::V3::Categories::CategoryShopperBrands
      end
    end
  end
end