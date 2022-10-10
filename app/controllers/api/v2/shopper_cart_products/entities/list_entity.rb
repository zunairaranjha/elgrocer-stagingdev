# frozen_string_literal: true

module API
  module V2
    module ShopperCartProducts
      module Entities
        class ListEntity < API::V1::ShopperCartProducts::Entities::ListEntity
          expose :updated_at, documentation: { type: 'DateTime', desc: 'Updated Time' }, format_with: :dateTime
        end
      end
    end
  end
end
