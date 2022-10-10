# frozen_string_literal: true

module API
  module V1
    module Retailers
      module Entities
        class ShowProfileEntity < API::BaseEntity
          root 'retailers', 'retailer'

          expose :id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :email, documentation: { type: 'String', desc: 'Email retailer' }, format_with: :string
          expose :company_name, documentation: { type: 'String', desc: 'Shop name' }, format_with: :string
          expose :phone_number, documentation: { type: 'String', desc: 'Phone number' }, format_with: :string
          expose :company_address, documentation: { type: 'String', desc: 'Shop address as text' }, format_with: :string
          expose :contact_email, documentation: { type: 'String', desc: 'Contact email of the retailer' }, format_with: :string
          expose :opening_time, documentation: { type: 'String', desc: 'Opening hours/opening days of the shop' }, format_with: :string
          expose :delivery_range, documentation: { type: 'Integer', desc: 'Delivery range' }, format_with: :integer
          expose :latitude, documentation: { type: 'Float', desc: 'Shop address geolocalized: latitude' }, format_with: :float
          expose :longitude, documentation: { type: 'Float', desc: 'Shop address geolocalized: longitude' }, format_with: :float
          expose :photo_url, documentation: { type: 'String', desc: 'An URL directing to a photo of the shop.' }, format_with: :string
          expose :location_id, documentation: { type: 'Integer', desc: 'Address location_id' }, format_with: :integer
          expose :location_name, documentation: { type: 'Integer', desc: 'Address location name' }, format_with: :string
          expose :contact_person_name, documentation: { type: 'Integer', desc: 'Contact person name' }, format_with: :string
          expose :is_opened, documentation: { type: 'Boolean', desc: 'Describes if retailer is opened' }, format_with: :bool
          expose :street, documentation: { type: 'Integer', desc: 'Address Street name' }, format_with: :string
          expose :building, documentation: { type: 'Integer', desc: 'Address building number' }, format_with: :string
          expose :apartment, documentation: { type: 'Integer', desc: 'Address apartment number' }, format_with: :string
          expose :flat_number, documentation: { type: 'Integer', desc: 'Address Flat number' }, format_with: :string
          expose :delivery_areas, documentation: { type: 'Array', desc: 'Delivery zones polygons', is_array: true }
          expose :min_basket_value, documentation: { type: 'Float', desc: 'Shop average rating' }, format_with: :float
          expose :is_featured, as: :featured, documentation: { type: 'Boolean', desc: 'Featured Flag' }, format_with: :bool
          expose :with_stock_level, as: :inventory_controlled, documentation: { type: 'Boolean', desc: 'Inventory Control flag' }, format_with: :bool

          private

          def photo_url
            object.photo.url(:medium)
          end

          def min_basket_value
            object.try(:min_basket_value)
            # object.retailer_delivery_zones.maximum("min_basket_value")
          end
        end
      end
    end
  end
end
