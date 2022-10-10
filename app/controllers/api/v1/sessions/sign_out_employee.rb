# frozen_string_literal: true

module API
  module V1
    module Sessions
      class SignOutEmployee < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :sessions do

          desc "Logs a Retailer out"

          params do
            optional :idle_logout, type: Boolean, desc: "If employee being force logged out", documentation: { example: false }
          end

          delete '/employee' do

            employee_count = Employee.where(retailer_id: current_employee.retailer_id).where("ARRAY[1] && employees.active_roles").where.not(activity_status: 1).count

            if employee_count > 1 or !current_employee.active_roles.include?(1)
              current_employee.logging_out(params[:idle_logout] ? 'Idle Logout' : 'Logout')
              { message: 'ok' }
            else
              error!(CustomErrors.instance.last_active_employee, 421)
            end
          end
        end
      end
    end
  end
end