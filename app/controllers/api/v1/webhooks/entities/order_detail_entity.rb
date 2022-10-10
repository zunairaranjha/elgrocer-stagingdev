module API
  module V1
    module Webhooks
      module Entities
        class OrderDetailEntity < API::BaseEntity
          root 'orders', 'order'

          def self.entity_name
            'order_detail'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :shopper_id, documentation: { type: 'Integer', desc: 'ID of the shopper' }, format_with: :integer
          expose :shopper_address_id, documentation: { type: 'Integer', desc: "Shopper's phone number"}, format_with: :integer
          expose :created_at, documentation: { type: 'String', desc: 'Date of ordering' }, format_with: :string
          expose :status, documentation: { type: 'String', desc: 'ID of the status' }, format_with: :string
          expose :payment_type, documentation: { type: 'String', desc: 'ID of the payment_type_id' }, format_with: :string
          expose :shopper_phone_number, documentation: { type: 'String', desc: "Shopper's phone number"}, format_with: :string
          expose :shopper_name, documentation: { type: 'String', desc: "Shopper's phone number"}, format_with: :string
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
          expose :retailer_phone_number, documentation: { type: 'String', desc: "Retailer's phone number" }, format_with: :string
          expose :retailer_company_name, documentation: { type: 'String', desc: "Retailer's company name" }, format_with: :string
          expose :retailer_opening_time, documentation: { type: 'String', desc: "Retailer's opening time" }, format_with: :string
          expose :retailer_company_address, documentation: { type: 'String', desc: "Retailer's address" }, format_with: :string
          expose :retailer_contact_email, documentation: { type: 'String', desc: "Retailer's contact email" }, format_with: :string
          expose :wallet_amount_paid, documentation: { type: 'Float', desc: "Shows if order is paid from wallet" }, format_with: :float
          expose :delivery_slot, documentation: { type: 'show_delivery_slot', desc: "Delivery slot detail" } do |result, options|
            API::V1::DeliverySlots::Entities::IndexEntity.represent object.delivery_slot, options.merge(week: (object.estimated_delivery_at + 1.day).strftime('%V').to_i)
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
          expose :receipt_no, documentation: { type: 'String', desc: 'receipt_no of the order' }, format_with: :string
          expose :picker_id, documentation: { type: 'Integer', desc: 'Picker Id' }, format_with: :integer
          expose :picker_name, documentation: { type: 'String', desc: 'Picker Name' }, format_with: :string
          expose :picker_phone_number, documentation: { type: 'String', desc: 'Picker Phone number' }, format_with: :string
          expose :order_link, documentation: { type: 'String', desc: 'Link of the order detail on admin panel' }, format_with: :string

          def total_value
            object.try("total_value")
          end

          def total_products
            object.try("total_products")
          end

          def status
            Order.statuses.key(object[:status_id])
          end

          def payment_type
            object.payment_type
          end

          def order_link
            "https://el-grocer-admin.herokuapp.com/admin/orders/#{object.id}"
          end

          def picker_name
            picker.try(:name)
          end

          def picker_phone_number
            picker.try(:phone_number)
          end

          def picker_id
            picker.try(:id)
          end

          def picker
            @picker ||= object.picker
          end

        end
      end
    end
  end
end
