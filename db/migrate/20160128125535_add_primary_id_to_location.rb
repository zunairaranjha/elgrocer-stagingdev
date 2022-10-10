class AddPrimaryIdToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :primary_location_id, :integer
  end
end
