class OrderStatusUpdateJob < ActiveJob::Base
  queue_as :order_status_update

  def perform(order)
    analytic = Analytic.find_by(owner: order, event_id: 59)
    if analytic and order.status_id != 5
      order.update(status_id: 5)
    end
  end
end

