class PromotionCodes::Base < ActiveInteraction::Base

  protected

  def retailer_exists
    errors.add(:retailer_id, 'Retailer does not exist or is closed') if Retailer.find_by(id: retailer_id, is_active: true, is_opened: true).nil?
  end

  def shopper_exists
    errors.add(:shopper_id, 'Shopper does not exist') if Shopper.find_by(id: shopper_id).nil?
  end

  def order_exists
    errors.add(:order_id, "Order does not exist") if Order.find_by(id: order_id).nil?
  end
end
