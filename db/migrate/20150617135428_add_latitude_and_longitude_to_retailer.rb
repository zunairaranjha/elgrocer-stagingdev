class AddLatitudeAndLongitudeToRetailer < ActiveRecord::Migration
  def change
    add_column :retailers, :latitude, :decimal, precision: 11, scale: 8
    add_column :retailers, :longitude, :decimal, precision: 11, scale: 8
  end
end