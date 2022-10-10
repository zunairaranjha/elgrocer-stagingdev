module API
  module V1
    module Payments
      class ThresholdApproval < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :payments do
          desc 'Approve or Reject Threshold payment'
      
          params do
            requires :order_id, type: Integer, desc: 'Order ID', documentation: { example: 12345678 }
            requires :is_approved, type: Boolean, desc: 'Accept or reject the Payment change', documentation: { example: true }
            requires :original_amount, type: Float, desc: 'The total amount of order', documentation: { example: 23.6 }
            requires :final_amount, type: Float, desc: 'Final amount to capture', documentation: { example: 25.6 }
            optional :reason, type: String, desc: 'Reason of rejection', documentation: { example: 'Amount is too big' }
          end
      
          post '/threshold_approval' do
            if current_employee and ((current_employee.employee_roles.pluck(:name).join(',').downcase).include? 'super')
              order = Order.find_by(id: params[:order_id])
              error!(CustomErrors.instance.order_not_found, 421) unless order
              error!(CustomErrors.instance.order_status('waiting for payment approval'), 421) unless order.status_id == 10
              params[:is_approved] ? order.update!(status_id: 13, final_amount: params[:final_amount]) : order.update!(status_id: 14)
              employee = Employee.joins(:order_allocations).where(order_allocations: {is_active: true, order_id: params[:order_id]}).first
              options = {
                'message': I18n.t("push_message.message_101"),
                'order_id': params[:order_id],
                'original_amount': params[:original_amount],
                'final_amount': params[:final_amount],
                'is_approved': params[:is_approved],
                'reason_to_reject': params[:reason],
                'message_type': 101
              }
              PushNotificationJob.perform_later(employee.registration_id, options, 0) if employee
              PaymentThreshold.create(employee_id: current_employee.id, order_id: params[:order_id], is_approved: params[:is_approved], rejection_reason: params[:reason])
              EmployeeActivity.add_activity('Payment threshold request processed', current_employee.id, params[:order_id])
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