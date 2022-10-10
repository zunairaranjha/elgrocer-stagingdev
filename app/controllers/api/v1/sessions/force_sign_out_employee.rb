# frozen_string_literal: true

module API
  module V1
    module Sessions
      class ForceSignOutEmployee < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :sessions do
      
          desc "Logs a Retailer out"
      
          params do
            requires :employee_id, type: Integer, desc: 'Id of Employee', documentation: { example: 20 }
          end
      
          delete '/force_logout_employee' do
            target_user = current_employee
            if target_user and (target_user.employee_roles.pluck(:name).join(',').downcase.include? 'super')
              Employee.find_by(id: params[:employee_id]).logging_out('Force Logout')
              {message: 'ok'}
            else
              error!(CustomErrors.instance.only_for_superuser, 421)
            end
          end
        end
      end      
    end
  end
end
