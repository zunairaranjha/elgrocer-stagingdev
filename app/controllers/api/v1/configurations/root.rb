module API
  module V1
    module Configurations
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::Configurations::GetConfiguration
        mount API::V1::Configurations::EmployeeConfiguration
      
      end
      
    end
  end
end