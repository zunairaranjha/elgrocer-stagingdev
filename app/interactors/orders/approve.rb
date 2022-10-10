class Orders::Approve < Orders::Base

  integer :order_id
  integer :shopper_id

  validate :order_exists
  validate :shopper_has_order
  validate :order_is_delivered

  def execute
    order = approve_order!
    order.retailer.approve_order_notify(order.id)
    order
  end

  private

  def order
    @order ||= Order.find(order_id)
  end

  def approve_order!
    order.update(is_approved: true, approved_at: Time.new, status_id: 3)
    order.save
    order
  end

  def order_is_delivered
    errors.add(:status_id, "Can't set this order as completed") unless Order.find_by(id: order_id).status == 'en_route'
  end
end
