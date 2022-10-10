class RenameTableRetailersHaveLocations < ActiveRecord::Migration
  def up
    rename_table :retailers_have_locations, :retailer_has_locations
  end
  def down
    rename_table :retailer_has_locations, :retailers_have_locations
  end
end
