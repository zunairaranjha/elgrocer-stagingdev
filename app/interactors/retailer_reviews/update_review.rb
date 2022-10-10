class RetailerReviews::UpdateReview < RetailerReviews::Base
  integer :retailer_id
  integer :shopper_id
  string :comment
  integer :overall_rating
  integer :delivery_speed_rating
  integer :order_accuracy_rating
  integer :quality_rating
  integer :price_rating

  validate :retailer_review_exists

  def execute
    update_review!
  end

  private

  def retailer_review
    @retailer_review ||= RetailerReview.find_by({retailer_id: retailer_id, shopper_id: shopper_id})
  end

  def update_params
    params = {
      comment: comment,
      overall_rating: overall_rating,
      delivery_speed_rating: delivery_speed_rating,
      order_accuracy_rating: order_accuracy_rating,
      quality_rating: quality_rating,
      price_rating: price_rating
    }
    params
  end

  def update_review!
    retailer_review.update(update_params)
    retailer_review.save!
    retailer_review
  end

end