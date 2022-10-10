module API
  module V1
    module Employees
      class AssignRole < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :employees do
          desc "Assign roles to employee."
      
          params do
            requires :employee_id, type: Integer, desc: 'Id of the employee', documentation: { example: 4 }
            requires :role_ids, type: String, desc: 'Ids of Roles assign to employee', documentation: { example: "1,2,3" }
          end
      
          put '/assign_role' do
            target_user = current_employee
            if target_user and ((target_user.employee_roles.pluck(:name).join(',').downcase).include? 'super')
              employee = Employee.find_by(id: params[:employee_id], is_active: true)
              if employee
                employee.update(active_roles: "{#{params[:role_ids]}}")
                {message: 'ok'}
              else
                error!(CustomErrors.instance.employee_not_exist, 421)
              end
            else
              error!(CustomErrors.instance.only_for_superuser, 421)
            end
          end
        end
      end      
    end
  end
end