# frozen_string_literal: true

module API
  module V1
    module Shoppers
      class Update < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :shoppers do
          desc "Allows updating shopper's profile.",
               entity: API::V1::Shoppers::Entities::UpdateEntity

          params do
            optional :password, type: String, desc: 'Retailer Password'
            optional :password_confirmation, type: String, desc: 'Retailer Password Confirmation'
            optional :name, type: String, desc: 'Retailer Password'
            optional :phone_number, type: String, desc: 'Retailer Password'
            optional :email, type: String, desc: 'Retailer Email'
            optional :language, type: String, desc: 'Language en / ar'
          end

          put '/update' do
            shopper = ::Shoppers::Update.run(params.merge(shopper_id: current_shopper.id))
            if shopper.valid?
              present shopper.result, with: API::V1::Shoppers::Entities::UpdateEntity
            else
              error!(shopper.errors, 422)
            end
          end

          # **************************************************************************
          # -------------------------- Change Language
          desc 'change selected language ', entity: API::V1::Sessions::Entities::SignInShopperEntity
          params do
            requires :language, type: String, desc: 'Language (en / ar) English:0  Arabic:1'
          end

          put '/update_language' do
            shopper = current_shopper
            error!(shopper.errors, 422) if shopper.nil?
            language = Shopper.languages.include?(params[:language]) ? params[:language] : 'en'
            if request.headers['Datetimeoffset'].present?
              shopper.update(language: language, date_time_offset: request.headers['Datetimeoffset'].to_s)
            else
              shopper.update(language: language)
            end
            present shopper, with: API::V1::Sessions::Entities::SignInShopperEntity
          end

          # -------------------------- Change Device
          desc 'Update device id for push notifications', entity: API::V1::Sessions::Entities::SignInShopperEntity
          params do
            requires :registration_id, type: String, desc: "Shopper's registration_id"
            requires :device_type, type: Integer, desc: "Shopper's device type (0 - Android, 1 - IOS)"
          end

          put '/update_device' do
            shopper = current_shopper
            error!(shopper.errors, 422) if shopper.nil?
            platform_type = request.headers['Loyalty-Id'].present? ? 1 : 0
            app_version = request.headers['Sdk-Version'] || request.headers['App-Version']
            shopper.save_push_token!(params[:registration_id], params[:device_type],
                                     app_version: app_version,
                                     date_time_offset: request.headers['Datetimeoffset'].to_s,
                                     platform_type: platform_type)
            present shopper, with: API::V1::Shoppers::Entities::UpdateEntity
          end

          # ---------------------------- Update Password
          desc 'Update Password for Shopper', entity: API::V1::Shoppers::Entities::UpdateEntity
          params do
            requires :old_password, type: String, desc: "Shopper's Old Password"
            requires :new_password, type: String, desc: "Shopper's Old Password"
            # requires :confirm_password, type: String, desc: "Shopper's Old Password"
          end

          put '/update_password' do
            shopper = current_shopper
            error!({ error_message: 'Invalid Shopper!' }) if shopper.nil?
            if shopper.valid_password?(params[:old_password]) # and params[:new_password] == params[:confirm_password]
              shopper.password = params[:new_password]
              shopper.save!
            else
              false
            end
          end
        end
      end
    end
  end
end