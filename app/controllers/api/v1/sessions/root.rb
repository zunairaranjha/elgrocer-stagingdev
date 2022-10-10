# frozen_string_literal: true

module API
  module V1
    module Sessions
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
    
        mount API::V1::Sessions::SignInRetailer
        mount API::V1::Sessions::SignInShopper
        mount API::V1::Sessions::SignInEmployee
        mount API::V1::Sessions::SignOutRetailer
        mount API::V1::Sessions::SignOutShopper
        mount API::V1::Sessions::SignOutEmployee
        mount API::V1::Sessions::ForceSignOutEmployee
        mount API::V1::Sessions::Authenticate
      end        
    end
  end
end