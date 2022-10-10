module API
  module V1
    module Campaigns
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V1::Campaigns::Index
        mount API::V1::Campaigns::Products
        mount API::V1::Campaigns::Show
        mount API::V1::Campaigns::ProductList
      end
    end
  end
end
