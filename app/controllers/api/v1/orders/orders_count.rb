# frozen_string_literal: true

module API
  module V1
    module Orders
      class OrdersCount < Grape::API
        version 'v1', using: :path
        format :json
        include TokenAuthenticable

        resource :orders do
          desc 'This API will return the count of the orders'

          params do
            optional :retailer_id, type: Integer, desc: 'Store ID'
          end

          get '/count' do
            error!(CustomErrors.instance.not_allowed, 421) unless current_employee
            if !((current_employee.active_roles & [4, 5]).blank? or params[:allocated_to_me])
              params[:retailer_id] ||= current_employee.retailer_id
              orders = Order.where(retailer_deleted: false, retailer_id: params[:retailer_id])
              orders = orders.joins("LEFT OUTER JOIN order_allocations ON order_allocations.order_id = orders.id AND order_allocations.is_active = 't'")
            else
              params[:retailer_id] = current_employee.retailer_id
              orders = Order.joins("JOIN order_allocations ON order_allocations.order_id = orders.id AND order_allocations.is_active = 't' AND order_allocations.employee_id = #{current_employee.id}")
              orders = orders.where(retailer_deleted: false, retailer_id: params[:retailer_id])
            end
            orders = orders.where("estimated_delivery_at between '#{Time.now - 2.week}' and '#{Time.now + Retailer.select(:show_pending_order_hours).find_by(id: params[:retailer_id])&.show_pending_order_hours.to_i.hours}'")
            orders = orders.where.not(retailer_id: nil)
            orders = orders.where.not(status_id: [-1, 2, 3, 4, 5, 8, 11, 13, 14])
            orders = orders.group('status_id')
            orders = orders.select('status_id, count(*) AS count').to_a
            hash = Hash.new
            Order.statuses.except(:waiting_for_online_payment_detail, :completed, :canceled, :delivered, :in_edit, :payment_approved, :payment_rejected).values.each { |os| hash[os] = 0 }
            orders.each { |order| hash[order.status_id] = order.count }
            orders = Order.where(status_id: [2, 11], retailer_id: params[:retailer_id]).where("estimated_delivery_at > '#{Time.now - 2.week}'")
            orders = orders.group('status_id')
            orders = orders.select('status_id, count(*) AS count').to_a
            orders.each { |order| hash[order.status_id] = order.count }
            present hash
          end
        end
      end
    end
  end
end
