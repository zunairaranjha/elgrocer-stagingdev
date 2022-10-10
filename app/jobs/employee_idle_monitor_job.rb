class EmployeeIdleMonitorJob
  @queue = :order_allocation

  def self.perform
    Analytic.add_activity("Employee Idle Tracker", Employee.find_by(id: 1))
    last_updated = ENV['EMPLOYEE_LAST_ACTIVITY_TIME'] || 10
    alive_time = ENV['EMPLOYEE_ALIVE_TIME'] || 60
    event = Event.find_or_create_by(name: 'Alive')
    result = Employee.joins("INNER JOIN order_allocations ON order_allocations.employee_id = employees.id AND order_allocations.is_active = 't'")
                 .joins("INNER JOIN orders ON orders.id = order_allocations.order_id AND orders.status_id NOT IN (-1,2,3,4,5,11)")
                 .joins("INNER JOIN employee_activities ON employee_activities.employee_id = employees.id AND (now() - employee_activities.created_at) >= '#{last_updated.to_i}minute'::interval")
                 .joins("INNER JOIN (SELECT employee_id, MAX(created_at) mx_created_at FROM employee_activities GROUP BY employee_id) emp_activity ON emp_activity.employee_id = employee_activities.employee_id AND employee_activities.created_at = emp_activity.mx_created_at")
                 .where("employees.activity_status <> 1")
                 .select("employees.*, COUNT(employees.retailer_id) OVER (PARTITION BY employees.retailer_id) AS employee_count, COUNT(DISTINCT order_allocations.id) FILTER (WHERE orders.status_id in (0,9)) AS pending_orders")
                 .select("count(DISTINCT order_allocations.id) FILTER (WHERE employee_activities.event_id = #{event.id} AND (now() - employee_activities.created_at) >= '#{alive_time}minute'::interval AND orders.status_id NOT IN (0,9)) AS working_orders")
                 .group("employees.id")
    result = Employee.select("emp.*").from(result, :emp)
    result = result.where("emp.employee_count > 1 AND (emp.pending_orders > 0 OR emp.working_orders > 0) AND ARRAY[1,2] && emp.active_roles")
    if result.length > 0
      employee_ids = result.map { |emp| emp.id }
      OrderAllocation.where(employee_id: employee_ids, is_active: true ).update_all(is_active: false)
      result.each do |employee|
        employee.logout_notification
        EmployeeActivity.add_activity("Idle Logout", employee.id)
      end
      Employee.where(id: employee_ids).update_all(activity_status: 1, updated_at: Time.now, authentication_token: nil, registration_id: nil)
      retailer_ids = result.map { |e| e.retailer_id }.uniq
      OrderReallocationJob.perform_later(nil, retailer_ids)
    end
  end
end