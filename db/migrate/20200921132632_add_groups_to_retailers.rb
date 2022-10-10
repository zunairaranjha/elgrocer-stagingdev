class AddGroupsToRetailers < ActiveRecord::Migration
  def change
    create_table :retailer_groups do |t|
      t.string :name

      t.timestamps
    end

    add_column :retailers, :retailer_group_id, :integer
  end
end
