# frozen_string_literal: true

module API
  module V2
    module LocationWithoutShops
      class Root < Grape::API
        version 'v2', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V2::LocationWithoutShops::Update
      end      
    end
  end
end