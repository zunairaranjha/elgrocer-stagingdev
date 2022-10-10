module API
  module V1
    module Webhooks
      module Entities
        class ShopperCartEntity < API::BaseEntity

          expose :cart_items, documentation: { type: 'Integer', desc: 'No of items in the cart' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'Integer', desc: 'Id of retailer' }, format_with: :integer
          expose :retailer_name, documentation: { type: 'String', desc: 'Retailer Name' }, format_with: :string
          expose :link_to_cart, documentation: { type: 'String', desc: 'Link to cart' }, format_with: :string

          private

          def link_to_cart
            "https://el-grocer-admin.herokuapp.com/admin/shopper_cart_products?utf8=%E2%9C%93&q%5Bshopper_id_equals%5D=#{options[:shopper_id]}&q%5Bretailer_id_equals%5D=#{object[:retailer_id]}&commit=Filter&order=id_desc"
          end
        end
      end
    end
  end
end