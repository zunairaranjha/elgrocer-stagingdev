class OrderAllocationJob < ActiveJob::Base
  queue_as :order_allocation

  def perform(order)
    return if OrderAllocation.where(order_id: order.id, is_active: true).exists?
    retailer = order.retailer
    if retailer&.is_active and retailer&.is_opened
      if order.status_id == 0
        allocate_orders(order.id, retailer, 1, order.status_id, 4)
        # roles = EmployeeRole.where("name ~* 'supervisor|picker'")
        # supervisor_role_id = roles.select { |role| role.name.downcase.include? 'supervisor' }.first.id
        # picker_role_id = roles.select { |role| role.name.downcase.include? 'picker' }.first.id
        # allocate_orders(order.id, retailer, picker_role_id, order.status_id, supervisor_role_id)
      elsif order.status_id == 9
        allocate_orders(order.id, retailer, 2, order.status_id, 4)
        # roles = EmployeeRole.where("name ~* 'supervisor|checkout'")
        # supervisor_role_id = roles.select { |role| role.name.downcase.include? 'supervisor' }.first.id
        # checkout_role_id = roles.select { |role| role.name.downcase.include? 'checkout' }.first.id
        # allocate_orders(order.id, retailer, checkout_role_id, order.status_id, supervisor_role_id)
        # elsif order.status_id == 11
        #   roles = EmployeeRole.where("name ilike 'supervisor' or name ilike '%deliver%'")
        #   supervisor_role_id = roles.select{ |role| role.name.downcase.include? 'supervisor' }.first.id
        #   delivery_role_id = roles.select{ |role| role.name.downcase.include? 'deliver' }.first&.id
        #   allocate_orders(order.id, retailer, delivery_role_id, order.status_id, supervisor_role_id)
      end
    end
  end

  def allocate_orders(order_id, retailer, role_id, status_id, supervisor_role_id)
    employees = retailer.employees.joins("LEFT OUTER JOIN order_allocations ON order_allocations.employee_id = employees.id AND order_allocations.is_active = 't'")
    #////////////////// to get employees on the base of orders
    # employees = employees.joins("LEFT OUTER JOIN orders ON orders.id = order_allocations.order_id AND orders.status_id = #{status_id}")
    # employees = employees.joins("LEFT OUTER JOIN order_allocations oas ON oas.order_id = orders.id AND oas.is_active = 't'")
    #////////////////// to get employees base on order positions count
    employees = employees.joins("LEFT OUTER JOIN orders ON orders.id = order_allocations.order_id AND orders.status_id = #{status_id}")
    employees = employees.joins("LEFT OUTER JOIN order_positions ON order_positions.order_id = orders.id")
    employees = employees.where("? = ANY(active_roles)", role_id)
    employees = employees.where(is_active: true)
    employees = employees.where.not(activity_status: 1)
    employees = employees.select("employees.id, employees.active_roles, employees.retailer_id, employees.registration_id, count(order_positions) AS pending_orders")
    employees = employees.group('employees.id').order('count(order_positions)')
    if employees.length > 0
      #////////////// Supervisor get half of the non supervisor employee ///////////////////////
      # supervisors = employees.select { |employee| employee.active_roles.include? supervisor_role_id }
      # supervisor_ids = supervisors.map { |employee| employee.id }
      # pickers = employees.select { |employee| employee.active_roles.include? role_id and !supervisor_ids.include? employee.id }
      # if supervisors.length > 0 and pickers.length > 0
      #   picker_hc = pickers.max_by { |picker| picker.pending_orders }.pending_orders.to_i
      #   picker_lc = pickers.min_by { |picker| picker.pending_orders }.pending_orders.to_i
      #   supervisor_lc = supervisors.min_by { |supervisor| supervisor.pending_orders }.pending_orders.to_i
      #   if picker_hc == picker_lc and supervisor_lc <= picker_hc * 0.5
      #     allocate_and_notify(status_id, supervisors.first, order_id)
      #   else
      #     allocate_and_notify(status_id, pickers.first, order_id)
      #   end
      # elsif pickers.length > 0
      #   allocate_and_notify(status_id, pickers.first, order_id)
      # elsif supervisors.length > 0
      #   allocate_and_notify(status_id, supervisors.first, order_id)
      # end
      #
      # #////////////// Both with the roles will have equal orders /////////////////////////////
      allocate_and_notify(status_id, employees.first, order_id)
    end
  end

  def allocate_and_notify(status_id, employee, order_id)
    OrderAllocation.create_allocation("Order #{Order.statuses.key(status_id).humanize}", employee.id, order_id, system_user)
    employee.new_allocation_notify(order_id)
  end

  def system_user
    @system_user ||= Employee.find_by(id: 1)
  end
end