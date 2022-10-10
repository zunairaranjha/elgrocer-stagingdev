class ShopperFavouriteRetailer < ActiveRecord::Base
    belongs_to :shopper, optional: true
    belongs_to :retailer, optional: true
end