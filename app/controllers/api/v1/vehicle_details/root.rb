module API
  module V1
    module VehicleDetails
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V1::VehicleDetails::Create
        mount API::V1::VehicleDetails::Update
        mount API::V1::VehicleDetails::Index
        mount API::V1::VehicleDetails::Delete
        mount API::V1::VehicleDetails::VehicleAttributes
      end
    end
  end
end

