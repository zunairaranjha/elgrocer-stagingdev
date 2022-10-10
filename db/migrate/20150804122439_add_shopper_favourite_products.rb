class AddShopperFavouriteProducts < ActiveRecord::Migration
  def up
    create_table(:shopper_favourite_products) do |t|
        t.integer :product_id, :null => true, :index => true
        t.integer :shopper_id, :null => true, :index => true
        t.timestamps
    end
  end

  def down
    drop_table(:shopper_favourite_products)
  end
end
