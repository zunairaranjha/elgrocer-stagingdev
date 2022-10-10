module API
  module V1
    module Webhooks
      module Entities
        class ShopperEntity < API::BaseEntity

          expose :id, documentation: { type: 'Integer', desc: 'Shopper Id' }, format_with: :integer
          expose :shopper_name, documentation: { type: 'String', desc: 'Shopper Name' }, format_with: :string
          expose :shopper_email, documentation: { type: 'String', desc: 'Shopper Email' }, format_with: :string
          expose :shopper_phone_number, documentation: { type: 'String', desc: 'Shopper Phone Number' }, format_with: :string
          expose :shopper_device, documentation: { type: 'String', desc: 'Shopper Device' }, format_with: :string
          expose :shopper_registration_date, documentation: { type: 'String', desc: 'Shopper Register Date' }, format_with: :string
          expose :shopper_last_login, documentation: { type: 'String', desc: 'Last Login' }, format_with: :string
          expose :shopper_profile_link, documentation: { type: 'String', desc: 'Shopper Profile Link' }, format_with: :string
          expose :feedback_link, as: :reviews_link, documentation: { type: 'String', desc: 'Order Reviews Link' }, format_with: :string

          private

          def shopper_name
            object[:name]
          end

          def shopper_email
            object[:email]
          end

          def shopper_phone_number
            object[:phone_number]
          end

          def shopper_device
            object.device_type
          end

          def shopper_registration_date
            object[:created_at]
          end

          def shopper_last_login
            object[:current_sign_in_at]
          end

          def shopper_profile_link
            "https://el-grocer-admin.herokuapp.com/admin/shoppers/#{object[:id]}"
          end

          def orders_link
            "https://el-grocer-admin.herokuapp.com/admin/orders?q%5Bshopper_id_eq%5D=#{object[:id]}"
          end

          def feedback_link
            "https://el-grocer-admin.herokuapp.com/admin/order_feedbacks?utf8=%E2%9C%93&q%5Border_shopper_id_eq%5D=#{object[:id]}&commit=Filter&order=id_desc"
          end

        end
      end
    end
  end
end
