class AddRetailerIdToSearchjoySearches < ActiveRecord::Migration
  def change
    add_column :searchjoy_searches, :retailer_id, :integer
  end
end
