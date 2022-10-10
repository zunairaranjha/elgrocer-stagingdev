module API
  module V1
    module Payments
      class ThresholdNotify < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :payments do
          desc 'Notify supervisor or super user that amount is greater tha the threshold'
      
          params do
            requires :order_id, type: Integer, desc: 'Order ID', documentation: { example: 2345678 }
            requires :original_amount, type: Float, desc: 'The total amount of order', documentation: { example: 23.6 }
            requires :final_amount, type: Float, desc: 'Final amount to capture', documentation: { example: 25.6 }
          end
      
          post '/threshold_notify' do
            error!(CustomErrors.instance.only_for_employee, 421) unless current_employee
            order = Order.find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
      
            supervisors = Employee.joins("INNER JOIN employee_roles ON employee_roles.id = ANY(employees.active_roles) AND employee_roles.name ILIKE 'supervisor'")
            supervisors = supervisors.where(retailer_id: current_employee.retailer_id).where.not(activity_status: 1)
            supervisors = Employee.joins("INNER JOIN employee_roles ON employee_roles.id = ANY(employees.active_roles) AND employee_roles.name ILIKE '%super%' AND employee_roles.name NOT ILIKE 'supervisor'") unless supervisors.length > 0
            options = {
              'message': I18n.t("push_message.message_100"),
              'retailer_name': current_employee.retailer.company_name,
              'order_id': params[:order_id],
              'original_amount': params[:original_amount],
              'final_amount': params[:final_amount],
              'message_type': 100,
              'retailer_id': current_employee.retailer_id
            }
            supervisors.each do |supervisor|
              PushNotificationJob.perform_later(supervisor.registration_id, options, 0)
            end
            EmployeeActivity.add_activity('Payment threshold approval requested', current_employee.id, params[:order_id])
            order.update!(status_id: 10, final_amount: params[:final_amount])
            {message: 'ok'}
          end
        end
      end
    end
  end
end