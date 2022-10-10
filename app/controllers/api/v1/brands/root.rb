
module API
  module V1
    module Brands
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::Brands::Show
        mount API::V1::Brands::New
        mount API::V1::Brands::Products
        mount API::V1::Brands::ProductsForShopper
      
      end      
    end
  end
end