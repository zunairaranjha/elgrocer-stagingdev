module API
  module V1
    module OrderSubstitutions
      class SelectingProducts < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :order_substitutions do
          desc 'Allows creation of an order substitutions', entity: API::V1::OrderSubstitutions::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: 'Order ID', documentation: { example: 2 }
          end

          get '/selecting_products' do
            target_user = current_employee || current_retailer || current_shopper
            order = Order.find(params[:order_id])
            Analytic.add_activity("Substitution started by #{target_user.class.name}", order)
            if current_shopper
              order.update(updated_at: Time.now)
              result = order.selecting_products_notify
              result = { sent: 1 }
              present result
            end
            if current_employee
              EmployeeActivity.add_activity('Substitution Started', current_employee.id, params[:order_id])
              { message: 'ok' }
            end
          end
        end
      end
    end
  end
end