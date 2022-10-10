# frozen_string_literal: true

module API
  module V1
    module CookingSteps
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::CookingSteps::Index
        mount API::V1::CookingSteps::Create
        mount API::V1::CookingSteps::Delete
        mount API::V1::CookingSteps::UpdatePhoto
      end      
    end
  end
end