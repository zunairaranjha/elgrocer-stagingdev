module API
  module V1
    module Employees
      class Update < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :shoppers do
      
          desc "Update device id for push notifications"
          params do
            requires :registration_id, type: String, desc: "Employee's registration_id"
          end
      
          put '/update_device' do
            employee = current_employee
            if employee.nil?
              error!(CustomErrors.instance.employee_not_exist, 421)
            else
              employee.save_push_token!(params[:registration_id])
              {message: 'ok'}
            end
          end
       end
      end
      
    end
  end
end