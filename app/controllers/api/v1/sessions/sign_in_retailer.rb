# frozen_string_literal: true

module API
  module V1
    module Sessions
      class SignInRetailer < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :sessions do
      
          desc "Authenticate reatiler and return retailer object with authentication token.
                Later the user is authenticated by the http header named Authentication-Token.",
                entity: API::V1::Sessions::Entities::SignInRetailerEntity
      
          params do
            requires :password, type: String, desc: "Retailer Password"
            requires :email, type: String, desc: "Retailer Email"
            optional :hardware_id, type: String, desc: "Retailer's hardware_id"
            optional :registration_id, type: String, desc: "Retailer's registration_id"
            optional :device_type, type: Integer, desc: "Retailer's device type (0 - Android, 1 - IOS)"
          end
      
          post do
            password = params[:password]
            email = params[:email]
            registration_id = params[:registration_id]
            hardware_id = params[:hardware_id]
            device_type = params[:device_type]
      
            retailer = Retailer.where(email: email.downcase).limit(1).first
            if retailer.nil?
              error!({error_code: 403, error_key: 1, error_message: "Retailer does not exist"},403)
            end
      
            if retailer.valid_password?(password)
              retailer.login(registration_id, device_type, hardware_id)
              present retailer, with: API::V1::Sessions::Entities::SignInRetailerEntity
            else
              error!({error_code: 403, error_key: 0,  error_message: "Wrong credentials"},403)
            end
          end
        end
      end
    end
  end
end