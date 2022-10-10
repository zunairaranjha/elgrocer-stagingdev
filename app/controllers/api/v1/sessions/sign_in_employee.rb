# frozen_string_literal: true

module API
  module V1
    module Sessions
      class SignInEmployee < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :sessions do
      
          desc "Authenticate employee and return employee object with authentication token.
                Later the user is authenticated by the http header named Authentication-Token."
      
          params do
            requires :password, type: String, desc: "Employee Password"
            requires :user_name, type: String, desc: "Employee Email"
            requires :registration_id, type: String, desc: "Employee's registration_id"
            optional :force_login, type: Boolean, desc: "To force login employee"
          end
      
          post '/employee' do
            password = params[:password]
            user_name = params[:user_name]
            registration_id = params[:registration_id]
            employee = Employee.find_by(user_name: user_name.downcase)
            if employee&.is_active
              if employee.authentication_token.nil? or params[:force_login]
                if employee.valid_password?(password)
                  employee = employee.login(registration_id, params[:force_login])
                  present employee, with: API::V1::Sessions::Entities::SignInEmployeeEntity
                else
                  error!(CustomErrors.instance.invalid_credential, 421)
                end
              else
                error!(CustomErrors.instance.already_login, 421)
              end
            else
              error!(CustomErrors.instance.employee_not_exist, 421)
            end
          end
        end
      end
    end
  end
end