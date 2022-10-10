class Orders::ChangeSlot < Orders::Base

  integer :order_id
  integer :shopper_id
  integer :delivery_slot_id, default: nil
  integer :week, default: nil

  validate :order_exists
  validate :shopper_has_order
  validate :order_is_pending
  validate :order_is_scheduled
  validate :validate_datetime
  validate :same_retailer_for_slot
  validate :retailer_is_opened
  validate :delivery_slot_exists
  validate :delivery_slot_invalid
  # validate :delivery_slot_orders_limit
  validate :delivery_slot_products_limit
  validate :retailer_delivery_type_invalid

  def execute
    order = convert_order!
    order.retailer.update_order_notify(order.id)
    order
  end

  private

  def order
    @order ||= Order.find(order_id)
  end

  def retailer
    @retailer ||= order.retailer
  end

  def delivery_slot
    DeliverySlot.find_by(id: delivery_slot_id, is_active: true) if delivery_slot_id.present? && DeliverySlot.exists?(id: delivery_slot_id)
  end

  def cal_estd_dlvry_at
    if week.to_i > 0
      @cal_estd_dlvry_at ||= delivery_slot.calculate_estd_delivery(Time.now, week)
    else
      @cal_estd_dlvry_at ||= delivery_slot.calculate_estimated_delivery_at(Time.now)
    end
  end

  def convert_order!
    if delivery_slot.present?
      order.update(delivery_slot_id: delivery_slot_id, estimated_delivery_at: cal_estd_dlvry_at)
    else
      order.update(delivery_slot_id: nil, delivery_type_id: nil, estimated_delivery_at: Time.now + 1.hour)
    end
    order.save
    order
  end

  def order_is_pending
    errors.add(:status_id, "Can't convert this order as #{order.status}") unless order.status == 'pending'
  end

  def order_is_scheduled
    errors.add(:not_scheduled, "this order is not scheduled") if order.delivery_slot_id.blank?
  end

  def same_retailer_for_slot
    errors.add(:retailer_not_same, "Can't change slot as retailer is changed") if order.delivery_slot.present? && delivery_slot.present? && (order.retailer_id != delivery_slot.retailer_delivery_zone.retailer_id)
  end

  def validate_datetime
    reminder_hours = order.retailer.schedule_order_reminder_hours
    errors.add(:time_elapsed, "Can't change slot as time elapsed") if order.delivery_slot.present? && order.estimated_delivery_at && (order.estimated_delivery_at < (Time.now - reminder_hours.second))
  end

  # def validate_slot
  #   errors.add(:not_scheduled, "Invalid delivery_slot_id") if delivery_slot_id.present? && delivery_slot.nil?
  # end

  def retailer_is_opened
    errors.add(:retailer_is_opened, 'Shop must be open') unless delivery_slot_id.present? || retailer.is_opened? && !retailer.is_schedule_closed?(order.shopper_address)
  end

  def delivery_slot_exists
    errors.add(:delivery_slot_id, 'DeliverySlot does not exist') if delivery_slot_id.present? && !DeliverySlot.exists?(id: delivery_slot_id)
  end

  def delivery_slot_invalid
    reminder_hours = retailer.schedule_order_reminder_hours
    skip_hours = retailer.delivery_slot_skip_hours
    errors.add(:delivery_slot_invalid, 'Invalid Delivery Slot') if delivery_slot.present? && cal_estd_dlvry_at < (Time.now - skip_hours.second)
  end

  # def delivery_slot_orders_limit
  #   errors.add(:delivery_slot_orders_limit, "Exceeding Delivery Slot Orders Limit") if delivery_slot.present? && delivery_slot.orders_limit > 0 && delivery_slot.orders.where('date(estimated_delivery_at) = ? and status_id != 4', cal_estd_dlvry_at.to_date).count >= delivery_slot.orders_limit
  # end

  # def orders_products_amount
  #   delivery_slot.orders.where('date(estimated_delivery_at) = ? and status_id != 4', cal_estd_dlvry_at.to_date).includes(:order_positions).sum(:amount).to_i
  # end

  def ds_limits_and_products
    # @ds_limits_and_products ||= DeliverySlot.joins("join (SELECT SUM(products_limit)*MIN(products_limit)/GREATEST(MIN(products_limit),1) total_limit, SUM(products_limit_margin) total_margin, SUM(orders_limit)*MIN(orders_limit)/GREATEST(MIN(orders_limit),1) total_orders_limit, start dsstart, day dsday FROM delivery_slots, retailer_delivery_zones sub_rdz WHERE retailer_delivery_zone_id = sub_rdz.id AND sub_rdz.retailer_id = #{retailer.id} group by start, day) AS totals on totals.dsstart = delivery_slots.start and totals.dsday = delivery_slots.day")
    #                                 .joins("join delivery_slots ds on ds.start = delivery_slots.start and ds.day = delivery_slots.day").joins("join retailer_delivery_zones rdz on rdz.id = ds.retailer_delivery_zone_id and rdz.retailer_id = #{retailer.id}")
    #                                 .joins("left outer join orders on orders.delivery_slot_id = ds.id and status_id != 4 and date(estimated_delivery_at) = '#{cal_estd_dlvry_at}'").joins("left outer join order_positions on order_positions.order_id = orders.id")
    #                                 .where(id: delivery_slot_id).select("delivery_slots.*, coalesce(sum(order_positions.amount),0) AS total_products, totals.total_limit, totals.total_margin, count(distinct orders.id) AS total_orders, totals.total_orders_limit").group("delivery_slots.id, totals.total_limit, totals.total_margin, totals.total_orders_limit").first
    @ds_limits_and_products ||= DeliverySlot.get_slot_info(delivery_slot_id, retailer.id, cal_estd_dlvry_at)
  end

  def delivery_slot_products_limit
    # errors.add(:delivery_slot_products_limit, "Exceeding Delivery Slot Limit") if delivery_slot.present? && delivery_slot.products_limit > 0 && ((orders_products_amount + order.order_positions.sum(:amount)) > (delivery_slot.products_limit + delivery_slot.products_limit_margin)) and ((orders_products_amount/(delivery_slot.products_limit * 1.0)) > 0.7)
    errors.add(:delivery_slot_products_limit, I18n.t("errors.slot_filled")) if delivery_slot.present? and ((ds_limits_and_products.total_limit > 0 and ((ds_limits_and_products.total_products + OrderPosition.where(order_id: order_id).sum(:amount)) > (ds_limits_and_products.total_limit + ds_limits_and_products.total_margin)) and ((ds_limits_and_products.total_products/(ds_limits_and_products.total_limit * 1.0)) > 0.7)) or (ds_limits_and_products.total_orders_limit > 0 and ds_limits_and_products.total_orders >= ds_limits_and_products.total_orders_limit))
  end

  def retailer_delivery_type_invalid
    errors.add(:retailer_delivery_type_invalid, "Oops! This time slot is taken now, please select another.") if (retailer.delivery_type_id == 0 && delivery_slot_id.present?) || (retailer.delivery_type_id == 1 && !delivery_slot_id.present?)
  end
end
