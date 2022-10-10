# frozen_string_literal: true

module API
  module V3
    module Retailers
      module Entities
        class DeliveryRetailerEntity < API::V2::Retailers::Entities::DeliveryRetailerEntity
          unexpose :ranking
          unexpose :photo1_url
          expose :is_featured, as: :featured, documentation: { type: 'Boolean', desc: 'Featured Flag' }, format_with: :bool
          expose :with_stock_level, as: :inventory_controlled, documentation: { type: 'Boolean', desc: 'Inventory Control flag' }, format_with: :bool
          expose :bg_photo_url, documentation: { type: 'String', desc: 'Background URl' }, format_with: :string
        end
      end
    end
  end
end
