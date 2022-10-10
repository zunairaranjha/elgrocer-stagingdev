# frozen_string_literal: true

module API
  module V1
    module OrderFeedbacks
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::OrderFeedbacks::Create
        mount API::V1::OrderFeedbacks::Tracking
      
      end
    end
  end
end