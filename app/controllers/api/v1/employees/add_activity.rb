# frozen_string_literal: true

module API
  module V1
    module Employees
      class AddActivity < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :employees do
          desc 'This allows to add activity for User'

          params do
            requires :activity, type: String, desc: 'Activity of the employee', documentation: { example: 'Login' }
            optional :employee_id, type: Integer, desc: 'Employee ID', documentation: { example: 2 }
          end

          post '/add_activity' do
            target_user = params[:employee_id] ? Employee.find_by(id: params[:employee_id]) : current_employee
            if target_user
              if params[:activity].downcase =~ /alive/
                event = Event.find_or_create_by(name: 'Alive')
                activity = EmployeeActivity.find_or_initialize_by(employee_id: target_user.id, event_id: event.id)
                activity.update(created_at: Time.now)
              else
                EmployeeActivity.add_activity(params[:activity], target_user.id)
              end
              { message: 'ok' }
            else
              error!(CustomErrors.instance.employee_not_exist, 421)
            end
          end
        end
      end
    end
  end
end
