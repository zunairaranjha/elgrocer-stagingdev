module API
  module V1
    module Webhooks
      module Entities
        class EmployeeEntity < API::BaseEntity

          expose :order_id, as: :order_number, documentation: { type: 'Integer', desc: 'Order Number' }, format_with: :integer
          expose :order_status, documentation: { type: 'String', desc: 'ID of the status' }, format_with: :string
    

          def order_status
            Order.statuses.key(object[:status_id])
          end

        end
      end
    end
  end
end
