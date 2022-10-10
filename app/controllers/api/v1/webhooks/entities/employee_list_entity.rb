module API
  module V1
    module Webhooks
      module Entities
        class EmployeeListEntity < API::BaseEntity

          def self.entity_name
            'employee_list'
          end

          expose :id, documentation: { type: 'Integer', desc: 'Id of employee' }, format_with: :integer
          expose :user_name, documentation: { type: 'String', desc: 'User Name of employee' }, format_with: :string
          expose :name, documentation: { type: 'String', desc: 'Name of Employee' }, format_with: :string
          expose :activity_status, documentation: { type: 'String', desc: 'Current Activity Status' }, format_with: :string
          expose :roles, documentation: { type: 'String', desc: 'Roles of employee' }, format_with: :string

          private

          def roles
            EmployeeRole.where(id: object.active_roles).pluck(:name).join(', ')
          end

          # def activity_status
          #   Employee.activity_statuses[object.activity_status]
          # end

        end
      end
    end
  end
end
