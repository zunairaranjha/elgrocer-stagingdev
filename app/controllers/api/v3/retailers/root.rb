module API
  module V3
    module Retailers
      class Root < Grape::API
        version 'v3', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V3::Retailers::Index
        mount API::V3::Retailers::IsCovered
        mount API::V3::Retailers::DeliveryRetailers

      end
    end
  end
end
