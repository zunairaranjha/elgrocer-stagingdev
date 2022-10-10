module API
  module V1
    module Webhooks
      module Entities
        class ShopperDetailEntity < API::BaseEntity
          # root 'shopper_details', 'shopper_detail'

          def self.entity_name
            'shopper_detail'
          end

          expose :id, documentation: { type: 'Integer', desc: 'Shopper Id' }, format_with: :integer
          expose :shopper_name, documentation: { type: 'String', desc: 'Shopper Name' }, format_with: :string
          expose :shopper_email, documentation: { type: 'String', desc: 'Shopper Email' }, format_with: :string
          expose :shopper_phone_number, documentation: { type: 'String', desc: 'Shopper Phone Number' }, format_with: :string
          expose :shopper_device, documentation: { type: 'String', desc: 'Shopper Device' }, format_with: :string
          expose :shopper_registration_date, documentation: { type: 'String', desc: 'Shopper Register Date' }, format_with: :string
          expose :shopper_last_login, documentation: { type: 'String', desc: 'Last Login' }, format_with: :string
          expose :total_orders, documentation: { type: 'Integer', desc: 'No of total orders of shopper' }, format_with: :integer
          expose :shopper_profile_link, documentation: { type: 'String', desc: 'Shopper Profile Link' }, format_with: :string
          expose :feedback_link, as: :reviews_link, documentation: { type: 'String', desc: 'Order Reviews Link' }, format_with: :string
          expose :latest_orders, using: API::V1::Webhooks::Entities::OrderDetailEntity, documentation: { type: 'order_detail', is_array: true }
          # expose :shopper_carts, using: API::V1::Webhooks::Entities::ShopperCartEntity, documentation: { is_array: true }
          expose :open_carts, documentation: { type: 'show_delivery_slot', desc: "Delivery slot detail" } do |result, options|
            API::V1::Webhooks::Entities::ShopperCartEntity.represent open_carts, options.merge(shopper_id: object[:shopper].id)
          end

          private

          def id
            object[:shopper].id
          end

          def shopper_name
            object[:shopper].name
          end

          def shopper_email
            object[:shopper].email
          end

          def shopper_phone_number
            object[:shopper].phone_number
          end

          def shopper_device
            object[:shopper].device_type
          end

          def shopper_registration_date
            object[:shopper].created_at
          end

          def shopper_last_login
            object[:shopper].current_sign_in_at
          end

          def shopper_profile_link
            "https://el-grocer-admin.herokuapp.com/admin/shoppers/#{object[:shopper].id}"
          end

          def orders_link
            "https://el-grocer-admin.herokuapp.com/admin/orders?q%5Bshopper_id_eq%5D=#{object[:shopper].id}"
          end

          def feedback_link
            "https://el-grocer-admin.herokuapp.com/admin/order_feedbacks?utf8=%E2%9C%93&q%5Border_shopper_id_eq%5D=#{object[:shopper].id}&commit=Filter&order=id_desc"
          end

          def total_orders
            Order.where(shopper_id: object[:shopper].id).count
          end

          def open_carts
            ShopperCartProduct.joins(:retailer).where(shopper_id: object[:shopper].id)
                              .select("count(*) AS cart_items, shopper_cart_products.retailer_id AS retailer_id, retailers.company_name AS retailer_name")
                              .group("shopper_cart_products.retailer_id, retailers.company_name")
          end

        end
      end
    end
  end
end
