# frozen_string_literal: true

module API
  module V1
    module Locations
      class Root < Grape::API
        # include TokenAuthenticable
        version 'v1', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V1::Locations::Index
        mount API::V1::Locations::Verification
        mount API::V1::Locations::Retailers
        mount API::V1::Locations::DeliveryRetailers
      end
    end
  end
end