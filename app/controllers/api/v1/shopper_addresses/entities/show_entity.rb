module API
  module V1
    module ShopperAddresses
      module Entities
        class ShowEntity < API::BaseEntity
          root 'shopper_addresses', 'shopper_address'

          def self.entity_name
            'show_address'
          end

          expose :id, documentation: { type: 'Integer', desc: 'Address id' }, format_with: :integer
          expose :address_name, documentation: { type: 'String', desc: 'Address name (e.g. "My place")' }, format_with: :string
          expose :street, documentation: { type: 'String', desc: 'Address street' }, format_with: :string
          expose :building_name, documentation: { type: 'String', desc: 'Address name (e.g. Skytower)' }, format_with: :string
          expose :apartment_number, documentation: { type: 'String', desc: 'Address apartment number' }, format_with: :string
          expose :location_name, documentation: { type: 'Integer', desc: 'Address location_id' }, format_with: :string
          expose :longitude, documentation: { type: 'float, desc: Address longitude' }, format_with: :float
          expose :latitude, documentation: { type: 'float, desc: Address longitude' }, format_with: :float
          expose :location_address, documentation: { type: 'string, desc: Delivery address' }, format_with: :string
          # expose :created_at, documentation: { type: 'String', desc: 'Address flat number' }, format_with: :string
          expose :default_address, documentation: { type: 'Boolean', desc: 'Return if address is default one' }, format_with: :bool
          expose :is_covered, documentation: { type: 'Boolean', desc: 'Address in EL-Grocer supported area, default: true' }, format_with: :bool
          expose :address_type_id, documentation: { type: 'Integer', desc: 'Address type, Apartement = 0, House = 1, Office = 2' }, format_with: :integer
          expose :additional_direction, documentation: { type: 'String', desc: 'Address additional direction' }, format_with: :string
          expose :floor, documentation: { type: 'String', desc: 'Address floor' }, format_with: :string
          expose :house_number, documentation: { type: 'String', desc: 'Address house number' }, format_with: :string
          expose :phone_number, documentation: { type: 'String', desc: 'Phone Number Associated with the Address' }, format_with: :string
          expose :shopper_name, documentation: { type: 'String', desc: 'Shopper name on this address' }, format_with: :string
          expose :administrative_area_level_1, as: :city, documentation: { type: 'String', desc: 'Shopper City name' }, format_with: :string
          expose :address_tag, using: API::V1::AddressTags::Entities::IndexEntity, documentation: { type: 'index_address_tag', is_array: true }

          private

          # not in use, to avoid N+1
          def is_covered
            true
          end
        end
      end
    end
  end
end