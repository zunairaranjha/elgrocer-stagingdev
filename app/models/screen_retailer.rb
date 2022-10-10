class ScreenRetailer < ActiveRecord::Base
  belongs_to :screen, optional: true
  belongs_to :retailer, optional: true
end