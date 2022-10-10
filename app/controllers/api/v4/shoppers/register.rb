# frozen_string_literal: true

module API
  module V4
    module Shoppers
      class Register < Grape::API
        version 'v4', using: :path
        format :json

        #API helpers
        helpers do
          def is_valid_phone phone_number
            phone_number.match?(/\A\+\d{12}\z/)
          end
        end

        resource :shoppers do
          desc "Authenticate reatiler and return retailer object with authentication token.
                Later the user is authenticated by the http header named Authentication-Token.",
               entity: API::V4::Shoppers::Entities::RegisterEntity

          params do
            requires :phone_number, type: String, desc: 'Smiles User Phone No'
            optional :registration_id, type: String, desc: "Shopper's registration_id"
          end

          post '/register' do
            error!(CustomErrors.instance.is_valid_phone, 421) unless is_valid_phone params[:phone_number]
            # shopper = Shopper.find_by(phone_number: params[:phone_number])
            registration_id = params[:registration_id]
            # device_type =   Shopper.device_types['smiles_sdk']
            device_type = request.headers['App-Agent'].include?('ios') ? 1 : 0
            app_version = request.headers['Sdk-Version']

            unless Shopper.where(phone_number: params[:phone_number]).exists?
              registered_shopper = ::Shoppers::RegisterSmiles.run(params)
              if registered_shopper.valid?
                registered_shopper
              else
                #=== TODO Handle custom Error Properly
                error!(CustomErrors.instance.shopper_registration_failed, 421)
              end
            end
            shopper = Shopper.find_by(phone_number: params[:phone_number])
            shopper.login(registration_id, device_type, request.headers['Datetimeoffset'].to_s, platform_type: Shopper.platform_types['smiles'], app_version: app_version, language: request.headers['Locale'])
            UserPlatformLog.add_logs(shopper)
            present shopper, with: API::V4::Sessions::Entities::SignInSmilesShopperEntity
            # if shopper.nil?
            #   registered_shopper = ::Shoppers::RegisterSmiles.run(params)
            #   if registered_shopper.valid?
            #     shopper = Shopper.find_by(phone_number: params[:phone_number])
            #     shopper.login(registration_id, device_type, request.headers['Datetimeoffset'].to_s)
            #     present shopper, with: API::V4::Sessions::Entities::SignInSmilesShopperEntity
            #   else
            #     error!(registered_shopper.errors, 422)
            #   end
            # else
            #   shopper.login(registration_id, device_type, request.headers['Datetimeoffset'].to_s)
            #   present shopper, with: API::V4::Sessions::Entities::SignInSmilesShopperEntity
            # end
          end
        end
      end
    end
  end
end