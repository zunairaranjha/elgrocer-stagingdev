class AddExcludeRetailerIdsToCampaigns < ActiveRecord::Migration[5.1]
  def change
    add_column :campaigns, :exclude_retailer_ids, :integer, array: true, :default => '{}'
  end
end
