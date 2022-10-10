# frozen_string_literal: true

module API
  module V1
    module Shoppers
      module Entities
        class UpdateEntity < API::BaseEntity
          root 'shoppers', 'shopper'
        
          expose :id, documentation: { type: "Integer", desc: "Shopper's id" }, format_with: :integer
          expose :email, documentation: { type: "String", desc: "Shopper's email" }, format_with: :string
          expose :name, documentation: { type: "String", desc: "Shopper's name" }, format_with: :string
          expose :phone_number, documentation: { type: "String", desc: "Shopper's phone" }, format_with: :string
          expose :invoice_city, documentation: { type: 'String', desc: 'Invoice address city name' }, format_with: :string
          expose :invoice_street, documentation: { type: 'String', desc: 'Invoice address street' }, format_with: :string
          expose :invoice_building_name, documentation: { type: 'String', desc: 'Invoice address building name' }, format_with: :string
          expose :invoice_apartment_number, documentation: { type: 'String', desc: 'Invoice address apartment number' }, format_with: :string
          expose :invoice_floor_number, documentation: { type: 'Integer', desc: 'number of a floor' }, format_with: :integer
          expose :invoice_location_id, documentation: { type: 'Integer', desc: 'invoice location id' }, format_with: :integer
          expose :invoice_location_name, documentation: { type: 'String', desc: 'invoice location name' }, format_with: :string
          expose :referral_code, documentation: { type: 'String', desc: 'invoice location name' }, format_with: :string
          expose :language, documentation: { type: 'Integer', desc: 'Language' }, format_with: :string
          expose :registration_id, documentation: { type: "String", desc: "Shopper's phone" }, format_with: :string
          expose :device_type, documentation: { type: "Integer", desc: "Shopper's id" }, format_with: :integer
        
          private
        
          def invoice_location_name
            object.invoice_location_name
          end
        end        
      end
    end
  end
end