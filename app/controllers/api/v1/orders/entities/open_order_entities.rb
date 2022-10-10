module API
  module V1
    module Orders
      module Entities
        class OpenOrderEntities < API::BaseEntity
          expose :id,as: :order_id,  documentation: { type: 'Integer', desc: 'id of Order' }, format_with: :integer
          expose :retailer_id, documentation: { type: 'Integer', desc: 'id of Retailer' }, format_with: :integer
          expose :retailer_company_name,as: :retailer_name, documentation: { type: 'String', desc: 'Name of Retailer' }, format_with: :string
        end
      end
    end
  end
end