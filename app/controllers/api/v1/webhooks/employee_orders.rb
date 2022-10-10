# frozen_string_literal: true

module API
  module V1
    module Webhooks
      class EmployeeOrders < Grape::API
        version 'v1', using: :path
        format :json

        resource :webhooks do
          desc 'Order Status according to Employee'

          params do
            requires :employee_id, type: Integer, desc: 'Employee Id', documentation: { example: 3 }
          end

          get '/employee_orders' do

            order_allocations = OrderAllocation.where(employee_id: params[:employee_id], is_active: true )
            order_allocations = order_allocations.joins("LEFT OUTER JOIN orders ON orders.id = order_allocations.order_id")
            order_allocations = order_allocations.select("order_allocations.order_id, orders.status_id")
            order_allocations = order_allocations.group("order_allocations.order_id, orders.status_id")

            present order_allocations, with: API::V1::Webhooks::Entities::EmployeeEntity

          end
        end
      end
    end
  end
end
