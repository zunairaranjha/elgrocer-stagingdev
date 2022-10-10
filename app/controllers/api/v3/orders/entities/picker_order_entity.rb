# frozen_string_literal: true

module API
  module V3
    module Orders
      module Entities
        class PickerOrderEntity < API::V2::Orders::Entities::PickerOrderEntity
          expose :created_at, documentation: { type: 'DateTime', desc: 'Date of ordering' }, format_with: :dateTime
          expose :estimated_delivery_at, documentation: { type: 'DateTime', desc: 'Estimated delivery time in case of schedule order' }, format_with: :dateTime
          expose :delivery_slot, override: true, documentation: { type: 'show_delivery_slot', desc: 'Delivery slot detail' } do |result, options|
            API::V2::DeliverySlots::Entities::IndexEntity.represent object.delivery_slot, options.merge(estimated_delivery: object.estimated_delivery_at.to_time)
          end
          expose :order_logs, using: API::V2::Analytics::Entities::ListEntity, documentation: { type: 'show_analytic', desc: 'Order loging', is_array: true }, :if => Proc.new { |product| options[:retailer] }
          expose :substitution_preference_key, documentation: { type: 'Integer', desc: 'Key of the Substitution Suggestions' }, format_with: :integer
          expose :substitution_preference_value, documentation: { type: 'String', desc: 'Value of the Substitution Suggestions' }, format_with: :string
          unexpose :payment_type_id
          expose :payment_type_change, as: :payment_type_id, documentation: { type: 'Integer', desc: 'payment_type_id' }, format_with: :integer

          def payment_type_change
            if locus_integration.select { |li| li.branch_code.to_i == object.retailer_delivery_zone_id || li.branch_code.blank? }.present?
              3
            else
              object.payment_type_id
            end
          end

          def substitution_preference_key
            object.orders_datum.detail['substitution_preference_key'] rescue nil
          end

          def substitution_preference_value
            object.orders_datum.detail['substitution_preference_value'] rescue nil
          end

          def locus_integration
            options[:locus_integration]
          end

        end
      end
    end
  end
end
