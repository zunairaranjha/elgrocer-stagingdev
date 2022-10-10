# frozen_string_literal: true

module API
  module V1
    module ShopperAddresses
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :shopper_addresses do
          desc 'Allows creation of an adress of a shopper. Requires authentication', entity: API::V1::ShopperAddresses::Entities::ShowEntity
          params do
            requires :longitude, type: Float, desc: 'Address longitude'
            requires :latitude, type: Float, desc: 'Address latitude'
            requires :location_address, type: String, desc: 'Shopper delivery address'
            optional :address_name, type: String, desc: 'Address name'
            optional :street, type: String, desc: 'Address street'
            optional :building_name, type: String, desc: 'Address building name'
            optional :apartment_number, type: String, desc: 'Address apartment number'
            optional :default_address, type: Boolean, desc: 'Default address flag - default: false'
            optional :address_type_id, type: Integer, desc: 'Address type, Apartement = 0, House = 1, Office = 2'
            optional :phone_number, type: String, desc: 'Phone Number To associate with that address', documentation: { example: '2345678' }
            optional :shopper_name, type: String, desc: 'Name To associate with that address', documentation: { example: 'Jhon' }
            optional :address_tag_id, type: Integer, desc: 'Address Tag Id to which address belons', documentation: { example: 1 }
          end

          post do
            full_params = params.merge(shopper_id: current_shopper.id, date_time_offset: request.headers['Datetimeoffset'])
            result = ::ShopperAddresses::Create.run(full_params)
            if result.valid?
              present result.result, with: API::V1::ShopperAddresses::Entities::ShowEntity
            else
              error!(result.errors, 422)
            end
          end
        end
      end
    end
  end
end