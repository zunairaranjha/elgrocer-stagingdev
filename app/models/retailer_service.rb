class RetailerService < ActiveRecord::Base
  has_many :retailer_has_services
  accepts_nested_attributes_for :retailer_has_services

  enum service: {delivery:1, click_and_collect:2} #, _prefix: :speed
  
end