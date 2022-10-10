module API
  module V1
    module Cities
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::Cities::Index
      end
      
    end
  end
end