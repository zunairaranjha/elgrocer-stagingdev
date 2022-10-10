# frozen_string_literal: true

module API
  module V2
    module Orders
      module Entities
        class CreateOrderEntity < API::V2::Orders::Entities::ShopperOrderHistory
          unexpose :collector_detail
          unexpose :vehicle_detail
          unexpose :pickup_location
          unexpose :positions
          unexpose :retailer_photo
          unexpose :credit_card
        end
      end
    end
  end
end
