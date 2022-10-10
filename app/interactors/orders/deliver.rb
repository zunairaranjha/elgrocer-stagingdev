class Orders::Deliver < Orders::Base
  integer :order_id
  integer :retailer_id

  validate :order_exists
  validate :retailer_has_order
  validate :order_en_route_or_complete

  def execute
    # Leave endpoint for android retailer compatibility
    # TO DO - Add Worker to use ShopperReminder after 3 hours
    order.update(status_id: 5)
    order
  end

  private

  def order
    @order ||= Order.find_by(id: order_id)
  end

  # def shopper
  #   @shopper ||= Shopper.find_by(id: order.shopper_id)
  # end

  def order_en_route_or_complete
    errors.add(:status_id, "Can't set this order as delivered") unless [2,3].include?(order.status_id)
  end
end
