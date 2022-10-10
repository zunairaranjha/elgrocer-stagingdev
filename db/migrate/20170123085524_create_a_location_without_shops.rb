class CreateALocationWithoutShops < ActiveRecord::Migration
  def change
    create_table :a_location_without_shops do |t|
      t.string :name
      t.integer :shopper_id
      t.string :email
	  t.decimal :latitude, precision: 11, scale: 8
	  t.decimal :longitude, precision: 11, scale: 8
	  t.boolean :is_notified

      t.timestamps null: false
    end
  end
end
