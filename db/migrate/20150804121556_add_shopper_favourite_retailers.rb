class AddShopperFavouriteRetailers < ActiveRecord::Migration
  def up
    create_table(:shopper_favourite_retailers) do |t|
        t.integer :retailer_id, :null => true, :index => true
        t.integer :shopper_id, :null => true, :index => true
        t.timestamps
    end
  end

  def down
    drop_table(:shopper_favourite_retailers)
  end
end
