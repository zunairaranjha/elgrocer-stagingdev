module API
  module V1
    module CollectorDetails
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::CollectorDetails::Create
        mount API::V1::CollectorDetails::Update
        mount API::V1::CollectorDetails::Index
        mount API::V1::CollectorDetails::Delete
      end
    end
  end
end