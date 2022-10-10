module API
  module V1
    module Chefs
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::Chefs::Index
        mount API::V1::Chefs::Create
        mount API::V1::Chefs::Update
      end
      
    end
  end
end