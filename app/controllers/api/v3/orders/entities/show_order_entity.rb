# frozen_string_literal: true

module API
  module V3
    module Orders
      module Entities
        class ShowOrderEntity < API::V2::Orders::Entities::ShowOrderEntity
          expose :created_at, documentation: { type: 'DateTime', desc: 'Date of ordering' }, format_with: :dateTime
          expose :estimated_delivery_at, documentation: { type: 'DateTime', desc: 'Estimated delivery time in case of schedule order' }, format_with: :dateTime
          expose :substituted_at, documentation: { type: 'DateTime', desc: 'Order Substitution Time' }, format_with: :dateTime
          expose :delivery_slot, override: true, documentation: { type: 'show_delivery_slot', desc: 'Delivery slot detail' } do |result, options|
            API::V2::DeliverySlots::Entities::IndexEntity.represent object.delivery_slot, options.merge(estimated_delivery: object.estimated_delivery_at.to_time)
          end
          expose :order_logs, using: API::V2::Analytics::Entities::ListEntity, documentation: { type: 'show_analytic', desc: 'Order loging', is_array: true }, :if => Proc.new { |product| options[:retailer] }
          expose :substitution_preference_key, documentation: { type: 'Integer', desc: 'Key of the Substitution Suggestions' }, format_with: :integer
          expose :substitution_preference_value, documentation: { type: 'String', desc: 'Value of the Substitution Suggestions' }, format_with: :string
          expose :is_smiles_user, documentation: { type: 'Boolean', desc: 'Is Smiles User' }, format_with: :bool
          expose :smiles_burn_points, documentation: { type: 'Integer', desc: 'Smiles Burn Points' }, format_with: :integer

          def substitution_preference_key
            object.orders_datum.detail["substitution_preference_key"] rescue nil
          end

          def substitution_preference_value
            object.orders_datum.detail["substitution_preference_value"] rescue nil
          end

          def is_smiles_user
            object.orders_datum.detail["is_smiles_user"] rescue false
          end

          def smiles_burn_points
            object.orders_datum.detail["transaction_ref_ids"].values.sum rescue nil
          end

        end
      end
    end
  end
end
