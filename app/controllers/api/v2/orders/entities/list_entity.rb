# frozen_string_literal: true

module API
  module V2
    module Orders
      module Entities
        class ListEntity < API::BaseEntity
          root 'orders', 'order'
        
          def self.entity_name
            'orders_list'
          end
        
          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :shopper_id, documentation: { type: 'Integer', desc: 'ID of the shopper' }, format_with: :integer
          expose :shopper_name, documentation: { type: 'String', desc: 'Name of the shopper' }, format_with: :string
          expose :shopper_phone_number, documentation: { type: 'String', desc: 'phone no of the shopper' }, format_with: :string
          expose :shopper_address_id, documentation: { type: 'Integer', desc: "Shopper's phone number"}, format_with: :integer
          expose :created_at, documentation: { type: 'String', desc: 'Date of ordering' }, format_with: :string
          expose :change_status, as: :status_id, documentation: { type: 'Integer', desc: 'ID of the status' }, format_with: :integer
          expose :payment_type_id, documentation: { type: 'Integer', desc: 'ID of the payment_type_id' }, format_with: :integer
          expose :shopper_address_name, documentation: { type: 'String', desc: "Shopper's address name"}, format_with: :string
          expose :shopper_address_area, documentation: { type: 'String', desc: "Shopper's phone number"}, format_with: :string
          expose :shopper_address_street, documentation: { type: 'String', desc: "Shopper's phone number"}, format_with: :string
          expose :shopper_address_building_name, documentation: { type: 'String', desc: "Shopper's phone number"}, format_with: :string
          expose :shopper_address_apartment_number, documentation: { type: 'String', desc: "Shopper's apartment number"}, format_with: :string
          expose :shopper_address_longitude, documentation: { type: 'Float', desc: "Shopper's longitude"}, format_with: :float
          expose :shopper_address_latitude, documentation: { type: 'Float', desc: "Shopper's latitude"}, format_with: :float
          expose :shopper_address_location_name, documentation: { type: 'String', desc: "Shopper's location_name" }, format_with: :string
          expose :shopper_address_location_address, documentation: { type: 'String', desc: "Shopper's location_address" }, format_with: :string
          expose :shopper_address_floor, documentation: { type: 'String', desc: "Shopper's address floor" }, format_with: :string
          expose :shopper_address_additional_direction, documentation: { type: 'String', desc: "Shopper's additional direction" }, format_with: :string
          expose :shopper_address_house_number, documentation: { type: 'String', desc: "Shopper's address house number" }, format_with: :string
          expose :shopper_address_type_id, documentation: { type: 'Integer', desc: 'ID of the payment_type_id' }, format_with: :integer
          expose :shopper_address_type, documentation: { type: 'String', desc: "Shopper's address name"}, format_with: :string
          expose :retailer_company_name, documentation: { type: 'String', desc: "Retailer's company name" }, format_with: :string
          expose :wallet_amount_paid, documentation: { type: 'Float', desc: "Shows if order is paid from wallet" }, format_with: :float
          expose :delivery_slot, merge: true, documentation: { type: 'show_delivery_slot', desc: "Delivery slot detail" } do |result, options|
            API::V1::DeliverySlots::Entities::IndexEntity.represent object.delivery_slot, options.merge(estimated_delivery: object.estimated_delivery_at.to_time)
          end
          expose :estimated_delivery_at, documentation: { type: 'String', desc: 'Estimated delivery time in case of schedule order' }, format_with: :string
          expose :service_fee, documentation: { type: 'Float', desc: "Retailer service fee" }, format_with: :float
          expose :delivery_fee, documentation: { type: 'Float', desc: "Delivery Fee" }, format_with: :float
          expose :rider_fee, documentation: { type: 'Float', desc: "Rider Fee" }, format_with: :float
          expose :promotion_code_realization, using: API::V1::Orders::Entities::PromotionCodeRealizationEntity,
                 documentation: { type: 'show_promotion_code_realization' }
          expose :shopper_note, documentation: { type: 'String', desc: "Shopper note for retailer" }, format_with: :string
          expose :total_value, documentation: { type: 'Float', desc: "Total value of order" }, format_with: :float
          expose :total_products, documentation: { type: 'Integer', desc: "Total products of order" }, format_with: :integer
          expose :vat, documentation: { type: 'Integer', desc: 'Value Added TAX %' }, format_with: :integer
          expose :price_variance, documentation: { type: 'Float', desc: 'Price Variance' }, format_with: :float
          expose :final_amount, documentation: { type: 'Float', desc: 'Final amount Entered by Retailer' }, format_with: :float
          expose :positions, documentation: { type: 'position_data', desc: 'Position Data',is_array: true }
          expose :images_links, documentation: { type: 'product_photos', desc: 'Products photos',is_array: true }
          expose :retailer_photo, documentation: { type: 'String', desc: 'Photo of Retailer' }, format_with: :string
          expose :retailer_delivery_zone_id, documentation: { type: 'Integer', desc: 'Retailer Delivery Zone Id' }, format_with: :integer
          expose :retailer_delivery_type_id, documentation: { type: 'Integer', desc: 'Photo of Retailer' }, format_with: :integer
          expose :retailer_opened, documentation: { type: 'Boolean', desc: 'Photo of Retailer' }, format_with: :bool
          expose :credit_card, using: API::V1::CreditCards::Entities::ShowEntity, documentation: { type: 'show_credit_card' }
        
          def total_value
            object.try("total_value")
          end
        
          def total_products
            object.try("total_products")
          end
        
          def change_status
            if options[:v1]
              object.status_id > 8 ? 1 : object.status_id
            else
              object.status_id
            end
          end
        
          def order_logs
            object.analytics
          end
        
          def images_links
            @image_links
          end
        
          def retailer_photo
            object.try("retailer_photo")
          end
        
          def retailer_delivery_type_id
            object.try("retailer_delivery_type_id")
          end
        
          def retailer_opened
            # puts(object.is_opened)
            object.try("retailer_opened")
          end
        
          def positions
            data = []
            @image_links = []
            object.positions_data&.each do |position|
              raw = position.split(",:")
              @image_links.push(raw[0])
              data.push({:image_url => raw[0], :was_in_shop => to_boolean(raw[1]), :amount => raw[2].to_i})
            end
            data
          end
        end        
      end
    end
  end
end