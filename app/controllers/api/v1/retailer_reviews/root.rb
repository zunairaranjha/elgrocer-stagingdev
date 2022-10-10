# frozen_string_literal: true

module API
  module V1
    module RetailerReviews
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::RetailerReviews::Index
        mount API::V1::RetailerReviews::Create
        mount API::V1::RetailerReviews::Update
      end      
    end
  end
end