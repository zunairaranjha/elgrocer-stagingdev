class DeleteLocations < ActiveRecord::Migration
  def change
    drop_table :locations
    # remove_column :products, :location_id
  end
end
