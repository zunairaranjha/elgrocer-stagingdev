class RetailerReviews::CreateReview < RetailerReviews::Base
  integer :retailer_id
  integer :shopper_id
  string :comment
  integer :overall_rating
  integer :delivery_speed_rating
  integer :order_accuracy_rating
  integer :quality_rating
  integer :price_rating

  validate :retailer_exists
  validate :retailer_has_no_reviews_from_shopper

  def execute
    create_review!
  end

  private

  def retailer
    @retailer ||= Retailer.find_by(id: retailer_id)
  end

  def create_params
    params = {
      retailer_id: retailer_id,
      shopper_id: shopper_id,
      comment: comment,
      overall_rating: overall_rating,
      delivery_speed_rating: delivery_speed_rating,
      order_accuracy_rating: order_accuracy_rating,
      quality_rating: quality_rating,
      price_rating: price_rating
    }
    params
  end

  def create_review!
    review = RetailerReview.create(create_params)
    review.save!
    review
  end

end