class OrderReallocationJob < ActiveJob::Base
  queue_as :order_allocation

  def perform(employee, retailer_ids = [])
    if retailer_ids.blank? and !employee.nil?
      retailer = employee.retailer
      if retailer&.is_active and retailer&.is_opened
        if employee.active_roles.include? 1
          order_ids = get_order_ids([0, 1], retailer, '1')
          allocate_orders(order_ids, retailer, 1, [0, 1], 4, employee) unless order_ids.blank?
        end
        if employee.active_roles.include? 2
          order_ids = get_order_ids([7, 9, 12], retailer, '7,12')
          allocate_orders(order_ids, retailer, 2, [7, 9, 12], 4, employee) unless order_ids.blank?
        end
        # order_ids = get_order_ids(11, employee) if delivery_role_id and employee.active_roles.include? 3
        # allocate_orders(order_ids, retailer, 3, 'Ready to deliver', 3) if order_ids.length > 0
      end
    else
      retailer_ids.each do |retailer_id|
        retailer = get_retailer(retailer_id)
        if retailer&.is_active and retailer&.is_opened
          order_ids = get_order_ids([0, 1], retailer, '1')
          allocate_orders(order_ids, retailer, 1, [0, 1], 4) unless order_ids.blank?
          order_ids = get_order_ids([7, 9, 12], retailer, '7,12')
          allocate_orders(order_ids, retailer, 2, [7, 9, 12], 4) unless order_ids.blank?
        end
      end
    end
  end

  def get_order_ids(type, retailer, progress_status)
    # if employee.logged_out?
    #   order_ids = Order.joins(:order_allocations).where(order_allocations: {is_active: true, employee_id: employee.id}).where(status_id: type).pluck(:id)
    #   employee.order_allocations.where(order_id: order_ids).update_all(is_active: false)
    #   order_ids
    # else
    retailer.orders.joins("LEFT JOIN order_allocations ON order_allocations.order_id = orders.id AND order_allocations.is_active = 't' AND orders.status_id in (#{type.join(',')})")
        .joins("LEFT JOIN order_positions ON order_positions.order_id = orders.id")
        .where(status_id: type).where("(order_allocations.order_id is null or order_allocations.owner_id = 1) AND orders.estimated_delivery_at <= '#{Time.now + retailer.show_pending_order_hours.hours}'")
        .select("orders.id, orders.status_id, count(order_positions) AS positions")
        .group("orders.id").having("count(order_allocations) filter (where orders.status_id in (#{progress_status})) < 1 ")
        .order("positions desc")
    # end
  end

  def allocate_orders(orders, retailer, role_id, status, supervisor_role_id, current_emp = nil )
    allocations = []
    order_ids = []
    employees = retailer.employees.where("? = ANY(active_roles)", role_id)
    employees = employees.where(is_active: true).where.not(activity_status: 1).select(:id, :active_roles, :retailer_id, :registration_id)
    if employees.length > 0
      system_user = Employee.find(1)
      event_ids = {}
      status.each do |status_id|
        event_ids[status_id.to_s] = Event.find_or_create_by(:name => "Order #{Order.statuses.key(status_id).humanize}").id
      end
      total_orders = orders.to_a
      emps = employees.map { |employee| employee.id }
      emp_push = []
      while total_orders.length > 0
        avg_capacity = ((total_orders.map { |order| order.positions }.sum / emps.length.to_f) + 1).to_i
        abv_avg = total_orders.select { |order| order.positions > avg_capacity }
        if abv_avg.length > 0
          i = 0
          while abv_avg.length > 0
            oa = OrderAllocation.find_or_initialize_by(order_id: total_orders[i].id, employee_id: emps.first, is_active: true)
            if oa.persisted?
              total_orders.delete_at(total_orders.index(abv_avg[i]))
            else
              oa.event_id = event_ids[total_orders[i].status_id.to_s]
              oa.created_at = Time.now
              oa.owner = system_user
              allocations << oa
              order_ids << total_orders.delete_at(total_orders.index(abv_avg[i]))
              emp_push << emps.shift
            end
            # allocations.push("(#{total_orders[i].id}, #{emps.first}, #{event_ids[total_orders[i].status_id.to_s]}, '#{Time.now - 4.hours}', #{system_user.id}, '#{system_user.class.name}')")
            # order_ids.push(total_orders.delete_at(total_orders.index(abv_avg[i])))
            abv_avg.delete_at(i)
          end
        else
          capacity = {}
          emps.length.times do |i|
            capacity[(i + 1).to_s] = avg_capacity
          end
          j = 1
          # loop_count Loop Breaker Counter, to hijack/overcome the infinite loop
          # it will decrement on allocating orders to employee and increment on switching employee
          # So if loop breaker counter is higher than number of employees then it allows allocating orders regardless of employee capacity
          loop_count = 0
          while total_orders.length > 0
            if j > emps.length
              j = 1
            end
            puts "cap: #{capacity[j.to_s]}, t.Ords: #{total_orders.length}, psn.Cnt: #{total_orders.first.positions}, t.emp: #{emps.length}"
            if (capacity[j.to_s] - total_orders.first.positions) >= 0 or (loop_count > emps.length)
              oa = OrderAllocation.find_or_initialize_by(order_id: total_orders.first.id, employee_id: emps[j - 1], is_active: true)
              capacity[j.to_s] = capacity[j.to_s] - total_orders.first.positions
              if oa.persisted?
                total_orders.delete_at(0)
              else
                oa.event_id = event_ids[total_orders.first.status_id.to_s]
                oa.created_at = Time.now
                oa.owner = system_user
                allocations << oa
                order_ids << total_orders.delete_at(0)
                emp_push << emps[j - 1]
              end
              # ("(#{total_orders.first.id}, #{emps[j - 1]}, #{event_ids[total_orders.first.status_id.to_s]}, '#{Time.now - 4.hours}', #{system_user.id}, '#{system_user.class.name}')")
              # total_orders.delete_at(0)
              loop_count -= 1
            else
              j += 1
              loop_count += 1
            end
          end
        end
      end
      #//////////// Allocation base on orders
      # skip = true
      # while order_ids.length > 0 do
      #   supervisors = employees.select { |employee| employee.active_roles.include? supervisor_role_id }.map { |employee| employee.id }
      #   pickers = employees.select { |employee| employee.active_roles.include? role_id and !supervisors.include? employee.id }.map { |employee| employee.id }
      #   skip = !skip
      #   system_user = Employee.find(1)
      #   pickers.each do |picker|
      #     break if order_ids.length < 1
      #     allocations.push("(#{order_ids.first[0]}, #{picker}, #{event_ids[order_ids.first[1].to_s]}, '#{Time.now - 4.hours}', #{system_user.id}, '#{system_user.class.name}')")
      #     order_ids.shift
      #   end
      #   skip = false unless pickers.length > 0
      #   next if skip
      #   supervisors.each do |supervisor|
      #     break if order_ids.length < 1
      #     allocations.push("(#{order_ids.first[0]}, #{supervisor}, #{event_ids[order_ids.first[1].to_s]}, '#{Time.now - 4.hours}', #{system_user.id}, '#{system_user.class.name}')")
      #     order_ids.shift
      #   end
      # end
      OrderAllocation.where(order_id: order_ids, is_active: true).update_all(is_active: false)
      OrderAllocation.import allocations
      # ActiveRecord::Base.connection.execute("INSERT INTO order_allocations (order_id, employee_id, event_id, created_at, owner_id, owner_type) VALUES #{allocations.join(',')}")
      if current_emp
        if current_emp.logged_out?
          notify_employees(emp_push, employees)
        else
          current_emp.new_allocation_notify
          employees.select { |emp| emp.id != current_emp.id }.each do |emp|
            emp.order_deallocated(emp)
          end
        end
      else
        notify_employees(emp_push, employees)
      end
    end
  end

  def get_retailer(id)
    Retailer.find_by(id: id)
  end

  def notify_employees(emps, employees)
    if emps.length > 0
      employees.select { |emp| emps.include? emp.id }.each do |emp|
        emp.new_allocation_notify
      end
    else
      employees.each do |emp|
        emp.new_allocation_notify
      end
    end
  end
end

