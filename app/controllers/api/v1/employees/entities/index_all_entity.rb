module API
  module V1
    module Employees
      module Entities
        class IndexAllEntity < API::BaseEntity
          root 'employees', 'employee'
        
          def self.entity_name
            'index_all_employee'
          end
        
          expose :id, documentation: { type: 'Integer', desc: 'Id of Employee' }, format_with: :integer
          expose :user_name, documentation: { type: 'String', desc: 'User Name of employee' }, format_with: :string
          expose :name, documentation: { type: 'String', desc: 'Name of Employee' }, format_with: :string
          expose :retailer_id, documentation: { type: 'Integer', desc: 'Retailer ID' }, format_with: :integer
          expose :retailer_name, documentation: { type: 'String', desc: 'Retailer Name' }, format_with: :string
          expose :activity_status, documentation: { type: 'Integer', desc: 'Current Activity Status' }, format_with: :integer
          expose :active_roles, documentation: { type: 'Array', desc: 'Current Active Roles' }
          expose :pending_orders, documentation: { type: 'Integer', desc: 'No of pending Orders' }, format_with: :integer
          expose :accepted_orders, documentation: { type: 'Integer', desc: 'No of pending Orders' }, format_with: :integer
          expose :ready_for_checkout_orders, documentation: { type: 'Integer', desc: 'No of pending Orders' }, format_with: :integer
          expose :checking_out_orders, documentation: { type: 'Integer', desc: 'No of pending Orders' }, format_with: :integer
          expose :ready_to_deliver_orders, documentation: { type: 'Integer', desc: 'No of pending Orders' }, format_with: :integer
          expose :en_route_orders, documentation: { type: 'Integer', desc: 'No of pending Orders' }, format_with: :integer
        
          private
        
          def activity_status
            Employee.activity_statuses[object.activity_status]
          end
        
        end  
      end
    end
  end
end
