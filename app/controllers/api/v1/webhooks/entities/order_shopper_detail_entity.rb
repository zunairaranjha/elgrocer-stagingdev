module API
  module V1
    module Webhooks
      module Entities
        class OrderShopperDetailEntity < API::BaseEntity
          expose :shopper, using: API::V1::Webhooks::Entities::ShopperEntity, documentation: { type: 'shopper_detail', is_array: true }
          expose :order, using: API::V1::Webhooks::Entities::OrderDetailEntity, documentation: { type: 'order_detail', is_array: true }
        end
      end
    end
  end
end
