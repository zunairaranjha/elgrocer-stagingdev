class DeliveryChannel < ActiveRecord::Base
  has_many :orders
end
