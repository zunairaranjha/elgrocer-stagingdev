class AddActiveToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :active, :bool, default: true
  end
end
