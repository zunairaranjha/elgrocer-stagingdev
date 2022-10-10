# frozen_string_literal: true

module API
  module V1
    module Retailers
      class UpdateProfile < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :retailers do
          desc "Changes fileds of the retailer's profile. Requires authentication.", entity: API::V1::Retailers::Entities::ShowProfileEntity
          params do
            # requires :retailer_id, type: Integer, desc: "ID of the retailer"
            optional :email, type: String, desc: 'Email of the retailer'
            requires :company_name, type: String, desc: 'Shop name'
            requires :company_address, type: String, desc: 'Shop address as text'
            optional :street, type: String, desc: 'Shop address as text'
            optional :building, type: String, desc: 'Shop address as text'
            optional :apartment, type: String, desc: 'Shop address as text'
            optional :flat_number, type: String, desc: 'Shop address as text'
            requires :phone_number, type: String, desc: 'Phone number'
            requires :contact_email, type: String, desc: 'Contact email of the retailer'
            requires :opening_time, type: String, desc: 'Opening hours/opening days of the shop'
            requires :delivery_range, type: Integer, desc: 'Delivery range'
            requires :latitude, type: Float, desc: 'Shop address geolocalized: latitude'
            requires :longitude, type: Float, desc: 'Shop address geolocalized: longitude'
            optional :contact_person_name, type: String, desc: 'Contact person name'
            optional :photo, type: Rack::Multipart::UploadedFile, desc: 'Photo shop'
            optional :location_id, type: Integer, desc: 'id of location'
          end
          put '/update' do
            result = ::Retailers::UpdateProfile.run(params.merge(retailer_id: current_retailer.id))
            if result.valid?
              present result.result, with: API::V1::Retailers::Entities::ShowProfileEntity
            else
              error!({ error_code: 403, error_message: result.errors }, 403)
            end
          end
        end
      end
    end
  end
end
