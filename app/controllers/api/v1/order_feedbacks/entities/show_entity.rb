# frozen_string_literal: true

module API
  module V1
    module OrderFeedbacks
      module Entities
        class ShowEntity < API::BaseEntity
          root 'order_trackings', 'order_tracing'

          def self.entity_name
            'show_tracking'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :created_at, documentation: { type: 'String', desc: 'Date of ordering' }, format_with: :string
          expose :estimated_delivery_at, documentation: { type: 'String', desc: 'estimated time to deliver order' }, format_with: :string
          expose :processed_at, documentation: { type: 'String', desc: 'Time when order was delivered' }, format_with: :string
          expose :status_id, documentation: { type: 'Integer', desc: 'ID of the status' }, format_with: :integer
          expose :retailer_company_name, documentation: { type: 'String', desc: "Retailer's company name" }, format_with: :string
          expose :photo_url, documentation: { type: 'String', desc: 'An URL directing to a photo of the shop.' }, format_with: :string
          expose :photo1_url, documentation: { type: 'String', desc: 'An URL directing to a photo of the shop.' }, format_with: :string
          expose :retailer_service_id, documentation: { type: 'Integer', desc: 'Retailer Service Id' }, format_with: :integer
          # expose :delivery_slot, using: API::V1::DeliverySlots::Entities::IndexEntity, documentation: { type: 'show_delivery_slot', desc: "Delivery slot detail" }

          private

          def photo_url
            object.retailer.try(:photo_url)
          end

          def photo1_url
            object.retailer.try(:photo1_url)
          end
        end
      end
    end
  end
end
