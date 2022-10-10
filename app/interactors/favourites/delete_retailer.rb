class Favourites::DeleteRetailer < Favourites::Base

    integer :shopper_id
    integer :retailer_id

    validate :retailer_exists

    def execute
        delete_favourite_retailer!
        result = {message: 'entry deleted'}
        result
    end

    private

    def retailer
        @retailer ||= Retailer.find(retailer_id)
    end

    def delete_favourite_retailer!
        ShopperFavouriteRetailer.find_by(shopper_id: shopper_id, retailer_id: retailer_id).destroy!
    end

    def shopper_has_favourite_retailer
        errors.add(:retailer_id, 'This retailer is not in your favourites list!') if ShopperFavouriteRetailer.find_by(shopper_id: shopper_id, retailer_id: retailer_id).nil?
    end

end
