class ShopperFavouriteProduct < ActiveRecord::Base
    belongs_to :shopper, optional: true
    belongs_to :product, optional: true
end