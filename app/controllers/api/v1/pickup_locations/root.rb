# frozen_string_literal: true

module API
  module V1
    module PickupLocations
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::PickupLocations::Index
      end
    end
  end
end