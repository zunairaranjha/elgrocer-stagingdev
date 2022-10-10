class PromotionCodeRealization < ActiveRecord::Base

  validates_presence_of :promotion_code, :shopper, :realization_date

  belongs_to :promotion_code, optional: true, foreign_key: :promotion_code_id
  belongs_to :shopper, optional: true
  belongs_to :order, optional: true
  belongs_to :retailer, optional: true

  scope :successful, -> { where.not(order_id: nil, retailer_id: nil) }
  scope :successful_without, -> (order_id) { where.not(order_id: [nil, order_id], retailer_id: nil) }
  #TODO Add Cron Job to remove unsuccessful realizations
end
