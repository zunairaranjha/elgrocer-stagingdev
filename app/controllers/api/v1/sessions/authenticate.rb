# frozen_string_literal: true

module API
  module V1
    module Sessions
      class Authenticate < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :sessions do
      
          desc "Authenticate Shopper and return shopper object with authentication token.
                Later the user is authenticated by the http header named Authentication-Token.",
                entity: API::V1::Sessions::Entities::SignInShopperEntity
      
          params do
            requires :code, type: String, desc: "token from provider"
            requires :clientId, type: String, desc: "client id of provider"
            requires :redirectUri, type: String, desc: "redirect uri for client app"
          end
      
          post '/:provider' do
            @oauth = "Oauth::#{params['provider'].titleize}".constantize.new(params)
            if @oauth.authorized?
              shopper = Shopper.from_auth(@oauth.formatted_user_data, nil)
              if shopper
                # shopper.login(registration_id, device_type)
                present shopper, with: API::V1::Sessions::Entities::SignInShopperEntity
              else
                error!({error_code: 403, error_key: 1, error_message: "This #{params[:provider]} account is used already"},403)
              end
            else
              error!({error_code: 403, error_key: 0,  error_message: "There was an error with #{params[:provider]}. please try again."},403)
            end
          end
        end
      end      
    end
  end
end