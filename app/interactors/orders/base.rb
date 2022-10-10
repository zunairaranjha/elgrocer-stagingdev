class Orders::Base < ActiveInteraction::Base

  protected

  def retailer_exists
    errors.add(:retailer_id, 'Retailer does not exist or is closed') if Retailer.find_by(id: retailer_id, is_active: true).nil?
  end

  def shopper_exists
    errors.add(:shopper_id, 'Shopper does not exist') if Shopper.find_by(id: shopper_id).nil?
  end

  def shopper_address_exists
    errors.add(:shopper_address_id, "Shopper's address does not exist") if ShopperAddress.find_by(id: shopper_address_id).nil?
  end

  def order_exists
    errors.add(:order_id, "Order does not exist") if Order.find_by(id: order_id).nil?
  end

  def products_are_not_empty
    errors.add(:products, 'Products are empty!') if products.empty?
  end

  def positions_are_not_empty
    errors.add(:positions, 'Positions are empty!') if positions.empty?
  end

  def retailer_has_order
    errors.add(:order_id, "You do not have this order!") if Order.find_by(retailer_id: retailer_id, id: order_id).nil?
  end

  def shopper_has_order
    errors.add(:order_id, "Shopper do not have this order!") if Order.find_by(shopper_id: shopper_id, id: order_id).nil?
  end

  def status_is_pending
    if order
      errors.add(:status_is_not_pending, "Order status is #{order.status}") unless [-1,0,6,8].include?(order.status_id)
    end
  end

  def order_is_old
    if order
      errors.add(:order_is_new, "You must give the retailer a chance to at least look at the order!") if order.status_id == 0 and order.created_at > 10.minutes.ago
    end
  end

  def accepted_promocode
    RetailerHasAvailablePaymentType.where(retailer_id: retailer_id, available_payment_type_id: payment_type_id, accept_promocode: true, retailer_service_id: 1).exists?
  end
end
