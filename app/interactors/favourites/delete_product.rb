class Favourites::DeleteProduct < Favourites::Base

    integer :shopper_id
    integer :product_id

    validate :product_exists

    def execute
        delete_favourite_product!
        result = {message: 'entry deleted'}
        result
    end

    private

    def product
        @product ||= Product.find(product_id)
    end

    def delete_favourite_product!
        ShopperFavouriteProduct.find_by(shopper_id: shopper_id, product_id: product_id).destroy!
    end

    def shopper_has_favourite_product
        errors.add(:product_id, 'This product is not in your favourites list!') if ShopperFavouriteProduct.find_by(shopper_id: shopper_id, product_id: product_id).nil?
    end

end
