# frozen_string_literal: true

module API
  module V2
    module Orders
      module Entities
        class ShowEntity < API::BaseEntity
          root 'orders', 'order'

          def self.entity_name
            'show_order'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :shopper_id, documentation: { type: 'Integer', desc: 'ID of the shopper' }, format_with: :integer
          expose :shopper_address_id, documentation: { type: 'Integer', desc: "Shopper's phone number" }, format_with: :integer
          expose :created_at, documentation: { type: 'String', desc: 'Date of ordering' }, format_with: :string
          expose :status_id, documentation: { type: 'Integer', desc: 'ID of the status' }, format_with: :integer
          expose :payment_type_id, documentation: { type: 'Integer', desc: 'ID of the payment_type_id' }, format_with: :integer

          expose :shopper_phone_number, documentation: { type: 'String', desc: "Shopper's phone number" }, format_with: :string
          expose :shopper_name, documentation: { type: 'String', desc: "Shopper's phone number" }, format_with: :string

          expose :shopper_address_name, documentation: { type: 'String', desc: "Shopper's address name" }, format_with: :string
          expose :shopper_address_area, documentation: { type: 'String', desc: "Shopper's phone number" }, format_with: :string
          expose :shopper_address_street, documentation: { type: 'String', desc: "Shopper's phone number" }, format_with: :string
          expose :shopper_address_building_name, documentation: { type: 'String', desc: "Shopper's phone number" }, format_with: :string
          expose :shopper_address_apartment_number, documentation: { type: 'String', desc: "Shopper's apartment number" }, format_with: :string
          expose :shopper_address_longitude, documentation: { type: 'Float', desc: "Shopper's longitude" }, format_with: :float
          expose :shopper_address_latitude, documentation: { type: 'Float', desc: "Shopper's latitude" }, format_with: :float
          expose :shopper_address_location_name, documentation: { type: 'String', desc: "Shopper's location_name" }, format_with: :string
          expose :shopper_address_location_address, documentation: { type: 'String', desc: "Shopper's location_address" }, format_with: :string
          expose :shopper_address_floor, documentation: { type: 'String', desc: "Shopper's address floor" }, format_with: :string
          expose :shopper_address_additional_direction, documentation: { type: 'String', desc: "Shopper's additional direction" }, format_with: :string
          expose :shopper_address_house_number, documentation: { type: 'String', desc: "Shopper's address house number" }, format_with: :string
          expose :shopper_address_type_id, documentation: { type: 'Integer', desc: 'ID of the payment_type_id' }, format_with: :integer
          expose :shopper_address_type, documentation: { type: 'String', desc: "Shopper's address name" }, format_with: :string
          expose :shopper_order_count, documentation: { type: 'Integer', desc: "Shopper total orders" }, format_with: :integer

          expose :retailer_phone_number, documentation: { type: 'String', desc: "Retailer's phone number" }, format_with: :string
          expose :retailer_company_name, documentation: { type: 'String', desc: "Retailer's company name" }, format_with: :string
          expose :retailer_opening_time, documentation: { type: 'String', desc: "Retailer's opening time" }, format_with: :string
          expose :retailer_company_address, documentation: { type: 'String', desc: "Retailer's address" }, format_with: :string
          expose :retailer_contact_email, documentation: { type: 'String', desc: "Retailer's contact email" }, format_with: :string
          expose :retailer_delivery_range, documentation: { type: 'Integer', desc: "Retailer's opening time" }, format_with: :integer

          expose :is_approved, documentation: { type: 'Boolean', desc: "Shows if order is approved by shopper" }, format_with: :bool
          expose :wallet_amount_paid, documentation: { type: 'Float', desc: "Shows if order is paid from wallet" }, format_with: :float

          expose :delivery_slot, using: API::V1::DeliverySlots::Entities::IndexEntity, documentation: { type: 'show_delivery_slot', desc: "Delivery slot detail" }
          expose :estimated_delivery_at, documentation: { type: 'String', desc: 'Estimated delivery time in case of schedule order' }, format_with: :string
          expose :service_fee, documentation: { type: 'Float', desc: "Retailer service fee" }, format_with: :float
          expose :delivery_fee, documentation: { type: 'Float', desc: "Delivery Fee" }, format_with: :float
          expose :rider_fee, documentation: { type: 'Float', desc: "Rider Fee" }, format_with: :float
          expose :vat, documentation: { type: 'Integer', desc: 'Value Added TAX %' }, format_with: :integer

          expose :order_positions, using: API::V1::Orders::Entities::ShowPositionEntity, documentation: { type: 'show_order_positions', is_array: true }
          expose :promotion_code_realization, using: API::V1::Orders::Entities::PromotionCodeRealizationEntity,
                 documentation: { type: 'show_promotion_code_realization' }

          expose :shopper_note, documentation: { type: 'String', desc: "Shopper note for retailer" }, format_with: :string

          expose :retailer, using: API::V1::Retailers::Entities::ShowRetailer, documentation: { type: 'show_retailer' }

          def retailer
            # may be we should use retailer_delivery_zone_id in cache key because min_basket value will vary based on on it.
            # Rails.cache.fetch("#{object.retailer_id}/retailer", expires_in: 12.hours) do
            retailer = object.retailer
            shopperAddress = object.shopper_address # ShopperAddress.find_by_id(object.shopper_address_id) if object.shopper_address_id
            min_basket_value = retailer.delivery_zones.with_point(shopperAddress.lonlat.to_s).maximum('retailer_delivery_zones.min_basket_value') if shopperAddress
            retailer.class_eval { attr_accessor :min_basket_value }
            retailer.min_basket_value = min_basket_value || object.try(:min_basket_value)
            retailer.class_eval { attr_accessor :retailer_delivery_zones_id }
            retailer.retailer_delivery_zones_id = retailer.delivery_zones.with_point(shopperAddress.lonlat.to_s).maximum('retailer_delivery_zones.id') if shopperAddress
            retailer
            # end
          end

          def shopper_order_count
            # object.shopper.orders.where("orders.created_at <= ?", object.created_at).count
            object.shopper.try(:order_count)
          end
        end
      end
    end
  end
end