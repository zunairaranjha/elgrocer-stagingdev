class ShopperReminder
  @queue = :reminder_queue

  def self.perform(order)
    if order.status == 'en_route'
      order.shopper.reminder_order_update_notify(order)
    end
  end
end
