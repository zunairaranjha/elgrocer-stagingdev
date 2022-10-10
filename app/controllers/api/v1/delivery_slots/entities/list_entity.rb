# frozen_string_literal: true

module API
  module V1
    module DeliverySlots
      module Entities
        class ListEntity < API::V1::DeliverySlots::Entities::IndexEntity
          unexpose :products_limit, :orders_limit, :total_products
        end
      end
    end
  end
end