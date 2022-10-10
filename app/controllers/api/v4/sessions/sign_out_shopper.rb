# frozen_string_literal: true

module API
  module V4
    module Sessions
      class SignOutShopper < Grape::API
        include TokenAuthenticable
        version 'v4', using: :path
        format :json
      
        resource :sessions do
      
          desc "Logs a Shopper out"
      
          params do
      
          end
      
          delete '/shopper' do
            current_shopper.delete_push_token
            result = {message: 'ok'}
            result
          end
        end
      end
    end
  end
end