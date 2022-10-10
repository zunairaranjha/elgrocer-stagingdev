# frozen_string_literal: true

module API
  module V2
    module Shoppers
      module Entities
        class ShowProfileEntity < API::BaseEntity
          root 'shoppers', 'shopper'
        
          expose :id, documentation: { type: 'Integer', desc: 'ID of a shopper' }, format_with: :integer
          expose :email, documentation: { type: 'String', desc: 'Shopper email' }, format_with: :string
          expose :name, documentation: { type: 'String', desc: 'Shopper name' }, format_with: :string
          expose :phone_number, documentation: { type: 'String', desc: 'Phone number' }, format_with: :string
          expose :invoice_city, documentation: { type: 'String', desc: 'Invoice address city name' }, format_with: :string
          expose :invoice_street, documentation: { type: 'String', desc: 'Invoice address street' }, format_with: :string
          expose :invoice_building_name, documentation: { type: 'String', desc: 'Invoice address building name' }, format_with: :string
          expose :invoice_apartment_number, documentation: { type: 'String', desc: 'Invoice address apartment number' }, format_with: :string
          expose :invoice_floor_number, documentation: { type: 'Integer', desc: 'number of a floor' }, format_with: :integer
          expose :invoice_location_id, documentation: { type: 'Integer', desc: 'invoice location id' }, format_with: :integer
          expose :invoice_location_name, documentation: { type: 'String', desc: 'invoice location name' }, format_with: :string
          expose :default_address_id, documentation: { type: 'Integer', desc: 'Default Shopper Address ID' }, format_with: :integer
          private
        
          def invoice_location_name
            object.invoice_location_name
          end
        
          def default_address_id
            object.default_address.id if object.default_address
          end
        end                
      end
    end
  end
end