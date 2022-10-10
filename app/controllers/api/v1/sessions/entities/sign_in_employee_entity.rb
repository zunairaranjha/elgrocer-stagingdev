# frozen_string_literal: true

module API
  module V1
    module Sessions
      module Entities
        class SignInEmployeeEntity < API::BaseEntity
          root 'employees', 'employee'
        
          expose :id, documentation: { type: 'Integer', desc: 'ID of the employee' }, format_with: :integer
          expose :user_name, documentation: { type: 'String', desc: 'User name of employee' }, format_with: :string
          expose :name, documentation: { type: 'String', desc: 'Name of employee' }, format_with: :string
          expose :retailer_id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :authentication_token, documentation: { type: "String", desc: "Employees's authentication token needed for each request that needs authentication." }, format_with: :string
          expose :activity_status, documentation: { type: "Integer", desc: "Employee's activity status ." }, format_with: :integer
          expose :roles, using: API::V1::Employees::Entities::RoleEntity, documentation: {type: 'show_role', is_array: true }
        
          private
        
          def roles
            EmployeeRole.where(id: object.active_roles)
          end
        
        end        
      end
    end
  end
end