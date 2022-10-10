class RetailerHasLocation < ActiveRecord::Base
  belongs_to :retailer, optional: true
  belongs_to :location, optional: true

  validates :location_id, presence: true
  validates :retailer_id, presence: true
  validates :min_basket_value, presence: true

  def name
    "#{retailer && retailer.company_name} : #{location.name}"
  end

end