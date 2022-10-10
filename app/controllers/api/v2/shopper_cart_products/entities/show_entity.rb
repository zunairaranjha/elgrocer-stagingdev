# frozen_string_literal: true

module API
  module V2
    module ShopperCartProducts
      module Entities
        class ShowEntity < API::V1::ShopperCartProducts::Entities::ShowEntity
          expose :created_at, documentation: { type: 'DateTime', desc: 'Created Time' }, format_with: :dateTime
          expose :updated_at, documentation: { type: 'DateTime', desc: 'Updated Time' }, format_with: :dateTime
        end
      end
    end
  end
end
