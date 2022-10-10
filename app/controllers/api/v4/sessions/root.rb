# frozen_string_literal: true

module API
  module V4
    module Sessions
      class Root < Grape::API
        version 'v4', using: :path, vendor: 'api'
        format :json
        mount API::V4::Sessions::SignInShopper
        mount API::V4::Sessions::SignOutShopper
      end        
    end
  end
end