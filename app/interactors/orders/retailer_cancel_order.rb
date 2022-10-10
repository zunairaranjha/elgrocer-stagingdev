class Orders::RetailerCancelOrder < Orders::Base

  integer :order_id
  integer :retailer_id
  string  :message, default: nil

  validate :retailer_has_order
  # validate :status_is_pending

  def execute
    result_order = cancel_order!
    shopper.cancel_order_notify(order, set_message, order.retailer_company_name)
    result_order
  end

  private

  def order
    @order ||= Order.find_by(id: order_id)
  end

  def shopper
    @shopper ||= Shopper.find_by(id: order.shopper_id)
  end

  def set_message
    message.blank? ? "store has cancelled" : message #|| I18n.t('cancel', scope: 'activerecord.messages.order')
  end

  def cancel_order!
    order.update_attributes(status_id: 4, canceled_at: Time.now, user_canceled_type: 1, message: set_message)
    order
  end

end