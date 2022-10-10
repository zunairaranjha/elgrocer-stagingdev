# frozen_string_literal: true

module API
  module V2
    module Retailers
      module Entities
        class ShowRetailerDeliveryZoneEntity < API::BaseEntity
          # def self.entity_name
          #   'show_payment_type'
          # end
          expose :id, documentation: { type: 'Integer', desc: "Retailer Delivery Zone ID"}, format_with: :integer
          # expose :delivery_zone_id, documentation: { type: 'Integer', desc: "Delivery Zone ID"}, format_with: :integer
          expose :min_basket_value, documentation: { type: 'Float', desc: 'Min basket value of retaiiler' }, format_with: :float
          expose :delivery_fee, documentation: { type: 'Float', desc: 'delivery fee' }, format_with: :float
          expose :rider_fee, documentation: { type: 'Float', desc: 'Rider fee on delivery' }, format_with: :float
        
        end                
      end
    end
  end
end