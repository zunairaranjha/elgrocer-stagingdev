# frozen_string_literal: true

module API
  module V3
    module Shoppers
      class Register < Grape::API
        version 'v3', using: :path
        format :json

        helpers do

          def get_otp(phone_number)
            (Redis.current.get (phone_number)).to_i
          end

        end

        resource :shoppers do

          desc "Authenticate reatiler and return retailer object with authentication token.
                Later the user is authenticated by the http header named Authentication-Token.",
               entity: API::V3::Shoppers::Entities::RegisterEntity

          params do
            requires :email, type: String, desc: "Retailer Email"
            requires :password, type: String, desc: "Retailer Password"
            requires :otp, type: Integer, desc: "Otp"
            optional :registration_id, type: String, desc: "Shopper's registration_id"
            optional :device_type, type: Integer, desc: "Shopper's device type (0 - Android, 1 - IOS)"
            optional :referrer_code, type: String, desc: "Shopper's Referrer Code"
            optional :name, type: String, desc: "Retailer Password"
            requires :phone_number, type: String, desc: "Retailer Password"
            optional :language, type: String, desc: "Language English:0  Arabic:1"
          end

          post '/register' do
            if get_otp(params[:phone_number].phony_normalized) == params[:otp]
              shopper = ::Shoppers::Register.run(params)
            else
              error!(CustomErrors.instance.invalid_otp, 421)
            end

            if shopper.valid?
              present shopper.result, with: API::V3::Shoppers::Entities::RegisterEntity
            else
              error!(shopper.errors, 422)
            end
          end
        end
      end
    end
  end
end