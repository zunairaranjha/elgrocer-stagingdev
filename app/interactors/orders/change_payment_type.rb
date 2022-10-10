class Orders::ChangePaymentType < Orders::Base

  integer :order_id
  integer :shopper_id
  integer :payment_type_id, default: nil

  validate :order_exists
  validate :shopper_has_order
  validate :retailer_has_payment_type
  
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

  def convert_order!
    PayfortJob.perform_later('void_authorization', order, nil, order.merchant_reference) if order.payment_type_id == 3 and order.payment_type_id != payment_type_id
    order.update(payment_type_id: payment_type_id)
    order.save
    order
  end

  def order_is_pending
    errors.add(:status_id, "Can't convert this order as #{order.status}") unless order.status == 'pending'
  end

  def retailer_has_payment_type
    errors.add(:payment_type_id, "Retailer do not consider this type of payment!") if RetailerHasAvailablePaymentType.find_by(retailer_id: order.retailer_id, available_payment_type_id: payment_type_id).nil?
  end
end
