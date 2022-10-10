# frozen_string_literal: true

module API
  module V2
    module Orders
      module Entities
        class ShowOrderEntity < API::BaseEntity
          root 'orders', 'order'

          def self.entity_name
            'show_order'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :shopper_id, documentation: { type: 'Integer', desc: 'ID of the shopper' }, format_with: :integer
          expose :retailer_service_id, documentation: { type: 'Integer', desc: 'ID of the Retailer Service' }, format_with: :integer
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
          # expose :shopper_order_count, documentation: { type: 'Integer', desc: "Shopper total orders" }, format_with: :integer

          # expose :retailer_phone_number, documentation: { type: 'String', desc: "Retailer's phone number" }, format_with: :string
          expose :retailer_company_name, documentation: { type: 'String', desc: "Retailer's company name" }, format_with: :string
          expose :retailer_photo, documentation: { type: 'String', desc: 'Photo of Retailer' }, format_with: :string

          expose :is_approved, documentation: { type: 'Boolean', desc: 'Shows if order is approved by shopper' }, format_with: :bool
          # expose :hardware_id, documentation: {type: 'String', desc: "Hardware Id of retailer"}, format_with: :string

          expose :delivery_slot, merge: true, documentation: { type: 'show_delivery_slot', desc: 'Delivery slot detail' } do |result, options|
            API::V1::DeliverySlots::Entities::IndexEntity.represent object.delivery_slot, options.merge(estimated_delivery: object.estimated_delivery_at.to_time)
          end
          expose :estimated_delivery_at, documentation: { type: 'String', desc: 'Estimated delivery time in case of schedule order' }, format_with: :string
          expose :service_fee, documentation: { type: 'Float', desc: 'Retailer service fee' }, format_with: :float
          expose :delivery_fee, documentation: { type: 'Float', desc: 'Delivery Fee' }, format_with: :float
          expose :rider_fee, documentation: { type: 'Float', desc: 'Rider Fee' }, format_with: :float
          expose :vat, documentation: { type: 'Integer', desc: 'Value Added TAX %' }, format_with: :integer

          # expose :order_positions, using: API::V2::Orders::Entities::ShowPositionEntity, documentation: {type: 'show_order_positions', is_array: true }
          expose :order_positions, merge: true, documentation: { type: 'show_delivery_slot', desc: 'Delivery slot detail' } do |result, options|
            API::V2::Orders::Entities::OrderPositionEntity.represent object.order_positions_views, retailer_with_stock: options[:retailer_with_stock]
          end
          expose :promotion_code_realization, using: API::V1::Orders::Entities::PromotionCodeRealizationEntity,
                 documentation: { type: 'show_promotion_code_realization' }

          expose :shopper_note, documentation: { type: 'String', desc: 'Shopper note for retailer' }, format_with: :string

          # expose :retailer, using: API::V1::Retailers::Entities::ShowRetailer, documentation: { type: 'show_retailer' }, :unless => Proc.new {|product| options[:retailer] }
          expose :order_logs, using: API::V2::Analytics::Entities::ShowEntity, documentation: { type: 'show_analytic', desc: 'Order loging', is_array: true }, :if => Proc.new { |product| options[:retailer] }
          expose :substituted_at, documentation: { type: 'String', desc: 'Date of ordering' }, format_with: :string
          expose :credit_card, using: API::V1::CreditCards::Entities::ShowEntity, documentation: { type: 'show_credit_card' }
          expose :price_variance, documentation: { type: 'Float', desc: 'Price Variance' }, format_with: :float
          expose :final_amount, documentation: { type: 'Float', desc: 'Final amount Entered by Retailer' }, format_with: :float
          expose :employee_name, documentation: { type: 'String', desc: 'Employee User name' }, format_with: :string
          expose :collector_detail, using: API::V1::CollectorDetails::Entities::IndexEntity, documentation: { type: 'show_collector_detail', is_array: true }
          expose :vehicle_detail, using: API::V1::VehicleDetails::Entities::ShowEntity, documentation: { type: 'show_vehicle_detail', is_array: true }
          expose :pickup_location, using: API::V1::PickupLocations::Entities::IndexEntity, documentation: { type: 'show_pickup_Location', is_array: true }
          expose :min_basket_value, documentation: { type: 'Float', desc: 'Min Basket Value' }, format_with: :float
          expose :delivery_type_id, documentation: { type: 'Integer', desc: 'Delivery Type Id instant/Schedule' }, format_with: :integer
          expose :tracking_url, documentation: { type: 'String', desc: 'Delivery Tracking Url' }, format_with: :string
          expose :retailer_slug, documentation: { type: 'String', desc: 'Slug of Retailer' }, format_with: :string, if: lambda { |instance, options| options[:for_web] }
          expose :adyen, documentation: { type: 'Boolean', desc: 'Adyen Order or Not' }, format_with: :bool

          def substituted_at
            object.order_substitutions.first.try(:created_at)
          end

          def employee_name
            object.try('employee_name').to_a[0]
          end

          def order_logs
            object.analytics # = Analytic.where(owner: object)
          end

          def collector_detail
            object.collector_detail
          end

          def vehicle_detail
            object.vehicle_detail
          end

          def pickup_location
            object.pickup_loc
          end

          def min_basket_value
            case object&.retailer_service_id
            when 1
              value = RetailerDeliveryZone.find_by(id: object&.retailer_delivery_zone_id)
              value&.min_basket_value
            when 2
              value = RetailerHasService.find_by(retailer_id: object&.retailer_id, is_active: true, retailer_service_id: 2)
              value&.min_basket_value
            end
          end

          def retailer_photo
            object&.retailer&.photo_url
          end

          def subs_shop_promotions
            object.order_substitutions.map { |sub| sub.shop_promotion }.compact
          end

          def tracking_url
            object.card_detail.to_h['tracking_url'].to_s if object.status_id == 2 && object.retailer_service_id == 1
          end

          def retailer_slug
            Retailer.select(:slug).find_by(id: object.retailer_id).slug
          end

          def adyen
            object.payment_type_id == 3 && object.card_detail.present? && object.card_detail['ps'].to_s.eql?('adyen')
          end

        end
      end
    end
  end
end
