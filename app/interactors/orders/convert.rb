class Orders::Convert < Orders::Base

  integer :order_id
  integer :shopper_id

  validate :order_exists
  validate :shopper_has_order
  validate :order_is_pending
  validate :order_is_scheduled
  validate :validate_datetime

  def execute
    order = convert_order!
    order.retailer.update_order_notify(order.id)
    order
  end

  private

  def order
    @order ||= Order.find(order_id)
  end

  def convert_order!
    order.update(delivery_slot_id: nil, delivery_type_id: nil, estimated_delivery_at: Time.now + 1.hour)
    order.save
    order
  end

  def order_is_pending
    errors.add(:status_id, "Can't convert this order as #{order.status}") unless order.status == 'pending'
  end

  def order_is_scheduled
    errors.add(:not_scheduled, "this order is not scheduled") if order.delivery_slot_id.blank?
  end

  def validate_datetime
    reminder_hours = order.retailer.schedule_order_reminder_hours
    errors.add(:time_elapsed, "this order cannot be converted to instant as time elapsed") if (delivery_slot = order.delivery_slot).present? && order.estimated_delivery_at && (order.estimated_delivery_at < (Time.now + reminder_hours.second))
  end
end
