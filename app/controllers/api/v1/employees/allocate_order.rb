module API
  module V1
    module Employees
      class AllocateOrder < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :employees do
          desc "Allocation Of order to Employee."
      
          params do
            requires :employee_id, type: Integer, desc: 'Id of Employee', documentation: { example: 20 }
            requires :order_id, type: Integer, desc: "Id of Order", documentation: { example: 387639 }
            optional :force_allocate, type: Boolean, desc: 'To force allocate order', documentation: { example: false }
          end
      
          post '/allocate_order' do
            if current_employee and !(current_employee.active_roles & [4, 5]).blank?
              employee = Employee.find_by(id: params[:employee_id], is_active: true)
              if employee
                order = Order.find_by("id = ? and status_id != ?", params[:order_id], 4)
                if order
                  order_allocation = order.order_allocations.where(is_active: true).first
                  if order_allocation and !params[:force_allocate]
                    error!(CustomErrors.instance.order_already_allocated, 421)
                  else
                    if [2,3,4,5].include?(order.status_id)
                      error!(CustomErrors.instance.order_status_not_appends, 421)
                    else
                      # OrderAllocation.where(order_id: order.id, is_active: true).update_all(is_active: false)
                      is_allocated = false
                      if [0,1,6].include?(order.status_id)
                        is_allocated = employee.allocate_pending(params[:order_id], current_employee, order.status_id)
                      elsif [9,10,12,13,14,11].include?(order.status_id)
                        is_allocated = employee.allocate_ready_for_checkout(params[:order_id], current_employee, order.status_id)
                      # elsif [11].include?(order.status_id)
                      #   is_allocated = employee.allocate_ready_to_deliver(params[:order_id], current_employee, order.status_id)
                      end
                      error!(CustomErrors.instance.employee_not_have_role, 421) unless is_allocated
                      {message: 'ok'}
                    end
                  end
                else
                  error!(CustomErrors.instance.order_not_found, 421)
                end
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