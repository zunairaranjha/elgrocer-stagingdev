module API
  module V1
    module Employees
      module Entities
        class EmployeeDetailEntity < API::BaseEntity
          root 'employees', 'employee'
        
          def self.entity_name
            'detail_employee'
          end
        
          expose :id, documentation: { type: 'Integer', desc: 'Id of Employee' }, format_with: :integer
          expose :user_name, documentation: { type: 'String', desc: 'User Name of employee' }, format_with: :string
          expose :name, documentation: { type: 'String', desc: 'Name of Employee' }, format_with: :string
          expose :retailer_id, documentation: { type: 'Integer', desc: 'Retailer ID' }, format_with: :integer
          expose :retailer_name, documentation: { type: 'String', desc: 'Retailer Name' }, format_with: :string
          expose :activity_status, documentation: { type: 'Integer', desc: 'Current Activity Status' }, format_with: :integer
          expose :pending_orders, documentation: { type: 'Integer', desc: 'No of pending Orders' }, format_with: :integer
          expose :current_order_id, documentation: { type: 'Integer', desc: 'Current Order' }, format_with: :integer
          expose :roles, using: API::V1::Employees::Entities::RoleEntity, documentation: {type: 'show_role', is_array: true }
          expose :activities, using: API::V1::Employees::Entities::ActivityEntity,  documentation: {type: 'show_role', is_array: true }
        
          private
        
          def activity_status
            Employee.activity_statuses[object.activity_status]
          end
        
          def roles
            EmployeeRole.where(id: object.active_roles)
          end
        
          def activities
            object.employee_activities.includes(:event).limit(20)
          end
        
        end                
      end
    end
  end
end