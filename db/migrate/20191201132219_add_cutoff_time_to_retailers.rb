class AddCutoffTimeToRetailers < ActiveRecord::Migration
  def change
    add_column :retailers, :cutoff_time, :integer, default: 0
  end
end
