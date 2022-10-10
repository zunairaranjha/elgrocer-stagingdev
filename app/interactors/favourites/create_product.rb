class Favourites::CreateProduct < Favourites::Base

    integer :shopper_id
    integer :product_id

    validate :product_exists
    validate :product_is_not_favourite

    def execute
        create_favourite_product!
        product
    end

    private

    def product
        @product ||= Product.find(product_id)
    end

    def create_favourite_product!
        entry = ShopperFavouriteProduct.create(
            shopper_id: shopper_id,
            product_id: product_id,
            created_at: Time.now
            )
        entry.save
        entry
    end



end
