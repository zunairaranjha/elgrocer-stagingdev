# frozen_string_literal: true

module API
  module V2
    module Shoppers
      class Register < Grape::API
        version 'v2', using: :path
        format :json

        resource :shoppers do

          desc "Authenticate shopper and return shopper object with authentication token.
                Later the user is authenticated by the http header named Authentication-Token.",
               entity: API::V2::Shoppers::Entities::RegisterEntity

          params do
            requires :password, type: String, desc: 'Retailer Password'
            requires :email, type: String, desc: 'Retailer Email'
            optional :registration_id, type: String, desc: "Shopper's registration_id"
            optional :device_type, type: Integer, desc: "Shopper's device type (0 - Android, 1 - IOS)"
            optional :referrer_code, type: String, desc: "Shopper's Referrer Code"
            optional :name, type: String, desc: 'Retailer Password'
            optional :phone_number, type: String, desc: 'Retailer Password'
            optional :language, type: String, desc: 'Language Englis:0  Arabic:1'
          end

          post '/register' do
            error!(CustomErrors.instance.update_to_latest, 421)
            # shopper = ::Shoppers::Register.run(params)
            # if shopper.valid?
            #   present shopper.result, with: API::V2::Shoppers::Entities::RegisterEntity
            # else
            #   error!(shopper.errors, 422)
            # end
          end
        end
      end
    end
  end
end
