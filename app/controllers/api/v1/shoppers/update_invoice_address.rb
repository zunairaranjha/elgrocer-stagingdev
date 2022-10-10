# frozen_string_literal: true

module API
  module V1
    module Shoppers
      class UpdateInvoiceAddress < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :shoppers do
      
          desc "Allows updating shopper's profile.",
                entity: API::V1::Shoppers::Entities::UpdateEntity
      
          params do
            optional :invoice_city, type: String, desc: "Address city"
            optional :invoice_street, type: String, desc: "Address street"
            optional :invoice_building_name, type: String, desc: "Address building name"
            optional :invoice_apartment_number, type: String, desc: "Address apartment number"
            optional :invoice_floor_number, type: Integer, desc: "Address floor number"
            optional :invoice_location_id, type: Integer, desc: "Address location id"
          end
      
          put '/invoice_address' do
            shopper_invoice_address = ::Shoppers::UpdateInvoiceAddress.run(params.merge(shopper_id: current_shopper.id))
            if shopper_invoice_address.valid?
              present shopper_invoice_address.result, with: API::V1::Shoppers::Entities::UpdateEntity
            else
              error!(shopper_invoice_address.errors, 422)
            end
          end
        end
      end
    end
  end
end