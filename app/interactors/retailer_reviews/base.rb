class RetailerReviews::Base < ActiveInteraction::Base

  private

  def retailer_exists
    errors.add(:no_retailer, 'Retailer does not exist') unless retailer.present?
  end

  def retailer_has_no_reviews_from_shopper

    # unless RetailerReview.find_by({retailer_id: retailer_id, shopper_id: shopper_id}).blank?
    #   puts "I will add an error"
    #   p RetailerReview.find_by({retailer_id: retailer_id, shopper_id: shopper_id})
    # else
    #   puts "I won't add an error"
    #   p RetailerReview.find_by({retailer_id: retailer_id, shopper_id: shopper_id})
    # end
    errors.add(:has_review, 'Retailer already has a review from you!') unless RetailerReview.find_by({retailer_id: retailer_id, shopper_id: shopper_id}).blank?
  end

  def retailer_review_exists
    errors.add(:no_retailer_review, 'Retailer review does not exist') unless retailer_review.present?
  end

end
