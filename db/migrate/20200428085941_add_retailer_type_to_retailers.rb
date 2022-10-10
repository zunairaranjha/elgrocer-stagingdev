class AddRetailerTypeToRetailers < ActiveRecord::Migration
  def change
    add_column :retailers, :retailer_type, :integer, default: 0
  end
end
