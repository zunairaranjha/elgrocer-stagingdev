# frozen_string_literal: true

module API
  module V1
    module Sessions
      module Entities
        class SignInRetailerEntity < API::BaseEntity
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
          expose :photo_url, documentation: { type: 'String', desc: "An URL directing to a photo of the shop." }, format_with: :string
          expose :is_opened, documentation: { type: 'Boolean', desc: "Describes if a shop is opened." }, format_with: :bool
          expose :authentication_token, documentation: { type: "String", desc: "Retailer's authentication token needed for each request that needs authentication." }, format_with: :string
        
          private
          def photo_url
            object.photo.url(:medium)
          end
        end                
      end
    end
  end
end