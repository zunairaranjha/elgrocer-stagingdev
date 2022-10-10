class Favourites::CreateRetailer < Favourites::Base

    integer :shopper_id
    integer :retailer_id

    validate :retailer_exists
    validate :retailer_is_not_favourite

    def execute
        create_favourite_retailer!
        retailer
    end

    private

    def retailer
        @retailer ||= Retailer.find(retailer_id)
    end

    def create_favourite_retailer!
        entry = ShopperFavouriteRetailer.create(
            shopper_id: shopper_id,
            retailer_id: retailer_id,
            created_at: Time.now
            )
        entry.save
        entry
    end



end
