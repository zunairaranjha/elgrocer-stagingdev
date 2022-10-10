class RetailerReview < ActiveRecord::Base
  belongs_to :retailer, optional: true
  belongs_to :shopper, optional: true

  def shopper_name
    shopper.name
  end

  def retailer_company_name
    retailer.company_name
  end

  def average_rating
    sum_of_ratings = 0

    sum_of_ratings += self.overall_rating
    sum_of_ratings += self.delivery_speed_rating
    sum_of_ratings += self.order_accuracy_rating
    sum_of_ratings += self.quality_rating
    sum_of_ratings += self.price_rating

    result = sum_of_ratings / 5
    result.round(1)
  end
end