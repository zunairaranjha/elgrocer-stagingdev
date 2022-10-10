module API
  module V1
    module Employees
      class Index < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :employees do
          desc "List of all employees."
      
          params do
            requires :limit, type: Integer, desc: 'Limit', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset', documentation: { example: 10 }
            optional :retailer_id, type: Integer, desc: 'Retailer id', documentation: { example: 16 }
          end
      
          get do
            target_user = current_employee
            if target_user and !(target_user.active_roles & [4,5]).blank?
              result = Employee.joins("LEFT OUTER JOIN order_allocations ON order_allocations.employee_id = employees.id AND order_allocations.is_active = 't'")
              result = result.joins("LEFT OUTER JOIN orders ON orders.id = order_allocations.order_id AND orders.status_id NOT IN (-1,3,4,5)")
              result = result.joins("LEFT OUTER JOIN employee_activities ON employee_activities.employee_id = employees.id AND date(employee_activities.created_at) = '#{Time.now.to_date}' AND employee_activities.order_id IS NOT NULL")
              result = result.joins("LEFT OUTER JOIN retailers ON retailers.id = employees.retailer_id")
              result = result.select("DISTINCT ON (employees.id) employees.id, employees.user_name, employees.name, employees.retailer_id, employees.activity_status,
                              count(distinct order_allocations.id) - count(distinct order_allocations.id) filter (where order_allocations.order_id = employee_activities.order_id  and orders.id = employee_activities.order_id and orders.status_id not in (0,9,11)) AS pending_orders,
                              array_agg(employee_activities.order_id ORDER BY employee_activities.created_at DESC) filter (where order_allocations.order_id = employee_activities.order_id and orders.id = employee_activities.order_id and orders.status_id not in (0,9,11) and employees.activity_status <> 1) AS current_order_id, retailers.company_name AS retailer_name")
              if params[:retailer_id]
                result = result.where(retailer_id: params[:retailer_id])
              elsif target_user.active_roles.include? 4
                result = result.where(retailer_id: target_user.retailer_id)
              end
              result = result.where(is_active: true)
              result = result.group("employees.id, retailers.company_name")
              result = result.order("employees.id, retailers.company_name, employees.activity_status")
              result = Employee.select("emp.*").from(result, :emp)
              result = result.order('emp.retailer_name, emp.activity_status')
              result = result.limit(params[:limit].to_i + 1).offset(params[:offset].to_i)
      
              is_next = result.length > params[:limit].to_i
              result = result.to_a.first(params[:limit].to_i)
              new_result = {next: is_next, employees: result }
      
              present new_result, with: API::V1::Employees::Entities::EmployeePaginationEntity
            else
              error!(CustomErrors.instance.only_for_superuser, 421)
            end
          end
      
          desc "List of all employees."
      
          params do
            requires :limit, type: Integer, desc: 'Limit', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset', documentation: { example: 10 }
            optional :retailer_id, type: Integer, desc: 'Retailer id', documentation: { example: 16 }
          end
      
          get '/all' do
            target_user = current_employee
            if target_user and !(target_user.active_roles & [4,5]).blank?
              result = Employee.joins("LEFT OUTER JOIN order_allocations ON order_allocations.employee_id = employees.id AND order_allocations.is_active = 't'")
              result = result.joins("LEFT OUTER JOIN orders ON orders.id = order_allocations.order_id AND orders.status_id NOT IN (-1,3,4,5)")
              result = result.joins("LEFT OUTER JOIN retailers ON retailers.id = employees.retailer_id")
              result = result.select("DISTINCT ON (employees.id) employees.id, employees.user_name, employees.name, employees.retailer_id, employees.activity_status, employees.active_roles,
                              count(distinct orders.id) filter (where orders.status_id = 0) AS pending_orders, count(distinct orders.id) filter (where orders.status_id = 1) AS accepted_orders,
                              count(distinct orders.id) filter (where orders.status_id = 9) AS ready_for_checkout_orders, count(distinct orders.id) filter (where orders.status_id = 12) AS checking_out_orders,
                              count(distinct orders.id) filter (where orders.status_id = 11) AS ready_to_deliver_orders, count(distinct orders.id) filter (where orders.status_id = 2) AS en_route_orders, retailers.company_name AS retailer_name")
              if params[:retailer_id]
                result = result.where(retailer_id: params[:retailer_id])
              elsif target_user.active_roles.include? 4
                result = result.where(retailer_id: target_user.retailer_id)
              end
              result = result.where(is_active: true)
              result = result.group("employees.id, retailers.company_name")
              result = result.order("employees.id, retailers.company_name, employees.activity_status")
              result = Employee.select("emp.*").from(result, :emp)
              result = result.order('emp.retailer_name, emp.activity_status')
              result = result.limit(params[:limit].to_i + 1).offset(params[:offset].to_i)
      
              is_next = result.length > params[:limit].to_i
              result = result.to_a.first(params[:limit].to_i)
              new_result = {next: is_next, employees: result }
      
              present new_result, with: API::V1::Employees::Entities::IndexPaginationEntity
            else
              error!(CustomErrors.instance.only_for_superuser, 421)
            end
          end
        end
      end
    end
  end
end