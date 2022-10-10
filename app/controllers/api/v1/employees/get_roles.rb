module API
  module V1
    module Employees
      class GetRoles < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :employees do
          desc "List of all Roles."
      
          params do
          end
      
          get '/roles' do
            target_user = current_employee
            if target_user and ((roles = target_user.employee_roles.pluck(:name).join(',').downcase).include? 'super')
              if roles.include? 'supervisor'
                result = EmployeeRole.where("name !~* 'super|deliver'")
              else
                result = EmployeeRole.where("name !~* 'superuser|super user|deliver'")
              end
              present result, with: API::V1::Employees::Entities::RoleEntity
            else
              error!(CustomErrors.instance.only_for_superuser, 421)
            end
          end
        end
      end      
    end
  end
end