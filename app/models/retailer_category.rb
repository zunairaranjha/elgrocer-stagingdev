class RetailerCategory < ActiveRecord::Base
  attr_accessor :select_all_retailers
  belongs_to :retailer, optional: true
  belongs_to :category, optional: true
end