module API
  module V1
    module Webhooks
      module Entities
        class RetailerDetailEntity < API::BaseEntity

          def self.entity_name
            'retailer_detail'
          end

          expose :id, documentation: { type: 'Integer', desc: 'Order Id' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Retailer Company Name' }, format_with: :string
          expose :phone_number, documentation: { type: 'String', desc: 'Retailer Phone number' }, format_with: :string
          expose :opening_time, documentation: { type: 'String', desc: 'Retailer Opening time' }, format_with: :string
          # expose :retailer_type, documentation: { type: 'String', desc: 'Retailer Type' }, format_with: :string
          # expose :retailer_category, with: API::V1::Webhooks::Entities::StoreTypeEntity, documentation: { type: 'show_store_type', is_array: true }
          expose :retailer_category, documentation: { type: 'String', desc: 'Retailer Store Type' }, format_with: :string

          private

          def name
            object[:company_name]
          end

          def retailer_category
            object.store_types.pluck(:name).join(', ')
          end

        end
      end
    end
  end
end
