class Orders::UpdateStatus < Orders::Base

  integer :order_id
  integer :retailer_id
  integer :status_id

  validate :order_exists
  validate :retailer_has_order
  validate :new_status_appends

  def execute
    order = update_order!
    # order.shopper.update_order_notify(order.id, order.status)
    # order.retailer.update_order_notify(order.id)
    order
  end

  private

  def order
    @order ||= Order.find_by(id: order_id)
  end

  def update_order!
    if status_id == 1
      order.update(status_id: status_id, accepted_at: Time.new)
      # order.send_order_placement_to_user #instead handle on model
    else
      order.update(status_id: status_id)
    end
    # order.save
    order
  end

  def new_status_appends
    errors.add(:status_id, "Status does not append!") unless Order.find_by(id: order_id).status_id+1 == status_id
  end
end
