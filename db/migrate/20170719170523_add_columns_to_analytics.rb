class AddColumnsToAnalytics < ActiveRecord::Migration
  def change
    remove_column :analytics, :shopper_id
    add_column :analytics, :owner_id, :integer
    add_column :analytics, :owner_type, :string
  end
end
