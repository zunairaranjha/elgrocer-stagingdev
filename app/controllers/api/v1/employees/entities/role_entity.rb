module API
  module V1
    module Employees
      module Entities
        class RoleEntity < API::BaseEntity
          root 'roles', 'role'
        
          def self.entity_name
            'show_role'
          end
        
          expose :id, documentation: { type: 'Integer', desc: 'ID of the employee' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Email retailer' }, format_with: :string
        
        end                
      end
    end
  end
end