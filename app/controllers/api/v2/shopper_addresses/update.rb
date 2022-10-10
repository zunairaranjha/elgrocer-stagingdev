# frozen_string_literal: true

module API
  module V2
    module ShopperAddresses
      class Update < Grape::API
        include TokenAuthenticable
        version 'v2', using: :path
        format :json

        resource :shopper_addresses do
          desc 'Allows update of an address of a shopper. Requires authentication', entity: API::V1::ShopperAddresses::Entities::ShowEntity
          params do
            requires :address_id, type: Integer, desc: 'Id of an address'
            optional :address_type_id, type: Integer, desc: 'Address type, Apartement = 0, House = 1, Office = 2'
            optional :address_name, type: String, desc: 'Address name'
            optional :street, type: String, desc: 'Address street'
            optional :building_name, type: String, desc: 'Address building name'
            optional :apartment_number, type: String, desc: 'Address apartment number'
            optional :longitude, type: Float, desc: 'Address longitude'
            optional :latitude, type: Float, desc: 'Address latitude'
            optional :location_address, String, desc: 'Shopper delivery address'
            optional :default_address, type: Boolean, desc: 'Default address flag'
            optional :additional_direction, type: String, desc: 'Address additional direction'
            optional :floor, type: String, desc: 'Address floor'
            optional :house_number, type: String, desc: 'Address House Number'
            optional :area, type: String, desc: 'Address Area'
            optional :phone_number, type: String, desc: 'Phone Number To associate with that address', documentation: { example: '2345678' }
            optional :shopper_name, type: String, desc: 'Name To associate with that address', documentation: { example: 'Jhon' }
            optional :address_tag_id, type: Integer, desc: 'Address Tag Id to which address belongs', documentation: { example: 1 }
          end

          put do
            full_params = params.merge(shopper_id: current_shopper.id, date_time_offset: request.headers['Datetimeoffset'])
            result = ::ShopperAddresses::Update.run(full_params)
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