module API
  module V1
    module Categories
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::Categories::Index
        mount API::V1::Categories::Create
        mount API::V1::Categories::Categories
        mount API::V1::Categories::ShopperCategories
        mount API::V1::Categories::CategoryBrands
        mount API::V1::Categories::CategoryShopperBrands
        mount API::V1::Categories::ElasticSearch
        mount API::V1::Categories::List
      end      
    end
  end
end