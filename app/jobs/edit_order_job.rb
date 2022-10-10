class EditOrderJob < ActiveJob::Base
  queue_as :order

  def perform(order_id, payment_type_id = 0)
    order = Order.find_by(id: order_id)
    Redis.current.del("order_#{order_id}")
    if order && (order.status_id == 8)
      order.status_id = 0
      PromotionCodeRealization.where(order_id: order.id).update_all(retailer_id: order.retailer_id)
      order.save!
      order.pending_order_notify
    elsif order && (order.status_id == -1) && payment_type_id.positive? && (payment_type_id < 3)
      order.status_id = 0
      order.payment_type_id = payment_type_id
      PromotionCodeRealization.where(order_id: order.id).update_all(retailer_id: order.retailer_id)
      order.save!
      order.pending_order_notify
    end
  end
end
