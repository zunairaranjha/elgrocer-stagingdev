module API
  module V1
    module Employees
      module Entities
        class IndexEntity < API::BaseEntity
          root 'employees', 'employee'
        
          def self.entity_name
            'index_employee'
          end
        
          expose :id, documentation: { type: 'Integer', desc: 'Id of Employee' }, format_with: :integer
          expose :user_name, documentation: { type: 'String', desc: 'User Name of employee' }, format_with: :string
          expose :name, documentation: { type: 'String', desc: 'Name of Employee' }, format_with: :string
          expose :retailer_id, documentation: { type: 'Integer', desc: 'Retailer ID' }, format_with: :integer
          expose :retailer_name, documentation: { type: 'String', desc: 'Retailer Name' }, format_with: :string
          expose :activity_status, documentation: { type: 'Integer', desc: 'Current Activity Status' }, format_with: :integer
          expose :pending_orders, documentation: { type: 'Integer', desc: 'No of pending Orders' }, format_with: :integer
          expose :current_order_id, documentation: { type: 'Integer', desc: 'Current Order' }, format_with: :integer
        
          private
        
          def activity_status
            Employee.activity_statuses[object.activity_status]
          end
        
          def current_order_id
            object.try("current_order_id").to_a[0]
          end
        
        
        end                
      end
    end
  end
end
