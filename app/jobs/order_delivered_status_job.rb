class OrderDeliveryStatusJob #< ActiveJob::Base
  @queue = :order

  def self.perform
    # order = Order.find_by(id: order_id)
    # if order && order.status_id == 1
    #   order.status_id = 5
    #   order.save!
    # elsif order && order.status_id == 2
    #   order.status_id = 5
    #   order.save!
    # end
    # Order.where("(orders.status_id = 1 and orders.accepted_at <= '#{Time.now - 999.hours}') or (orders.status_id = 2 and orders.processed_at <= '#{Time.now - 6.hours}') or (orders.status_id = 3)").update_all(status_id: 5, updated_at: Time.now)
    time = Integer(Redis.current.get('en_route_to_deliver_time') || SystemConfiguration.find_by_key('en_route_to_deliver_time').value)
    Order.where("orders.status_id = 2 and orders.processed_at <= '#{Time.now - time.hours}' 
      or orders.status_id = 11 and orders.estimated_delivery_at <= '#{Time.now - time.hours}'").update_all(status_id: 5, updated_at: Time.now)
  end
end
