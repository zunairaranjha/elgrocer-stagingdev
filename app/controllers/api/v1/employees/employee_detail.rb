module API
  module V1
    module Employees
      class EmployeeDetail < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :employees do
          desc "Detail of the Employee."
      
          params do
            requires :employee_id, type: Integer, desc: 'Id of Employee', documentation: { example: 20 }
          end
      
          get '/detail' do
            target_user = current_employee
            if target_user and ((roles = target_user.employee_roles.pluck(:name).join(',').downcase).include? 'super')
              result = Employee.joins("LEFT OUTER JOIN order_allocations ON order_allocations.employee_id = employees.id AND order_allocations.is_active = 't'")
              result = result.joins("LEFT OUTER JOIN employee_activities ON employee_activities.employee_id = employees.id AND employee_activities.order_id = order_allocations.order_id AND date(employee_activities.created_at) = '#{Time.now.to_date}'")
              result = result.joins("LEFT OUTER JOIN retailers ON retailers.id = employees.retailer_id")
              result = result.select("DISTINCT ON (employees.id) employees.id, employees.user_name, employees.name, employees.retailer_id, employees.activity_status, employees.active_roles, count(order_allocations) AS pending_orders, employee_activities.order_id AS current_order_id, retailers.company_name AS retailer_name")
              result = result.where(id: params[:employee_id], is_active: true)
              result = result.group("employees.id, employee_activities.order_id, retailers.company_name")
              if result.length > 0
                present result.first, with: API::V1::Employees::Entities::EmployeeDetailEntity
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