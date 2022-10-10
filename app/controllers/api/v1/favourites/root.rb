# frozen_string_literal: true

module API
  module V1
    module Favourites
      class Root < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::Favourites::IndexRetailers
        mount API::V1::Favourites::IndexProducts
      
        mount API::V1::Favourites::CreateProducts
        mount API::V1::Favourites::CreateRetailers
      
        mount API::V1::Favourites::DeleteProduct
        mount API::V1::Favourites::DeleteRetailer
      
      end
    end
  end
end