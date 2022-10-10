# frozen_string_literal: true

module API
  module V1
    module OrderFeedbacks
      module Entities
        class ListEntity < API::V1::OrderFeedbacks::Entities::ShowEntity
          expose :created_at, documentation: { type: 'DateTime', desc: 'Date of ordering' }, format_with: :dateTime
          expose :estimated_delivery_at, documentation: { type: 'DateTime', desc: 'estimated time to deliver order' }, format_with: :dateTime
          expose :processed_at, documentation: { type: 'DateTime', desc: 'Time when order was delivered' }, format_with: :dateTime
        end
      end
    end
  end
end
