class Retailers::Base < ActiveInteraction::Base

  private

  def retailer_exists
    errors.add(:retailer_id, 'Retailer does not exist') unless retailer.present?
  end

end
