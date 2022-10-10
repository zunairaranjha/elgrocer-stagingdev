class AvailablePaymentType < ActiveRecord::Base
  has_many :retailer_has_available_payment_types
  has_many :retailers, through: :retailer_has_available_payment_types


end
