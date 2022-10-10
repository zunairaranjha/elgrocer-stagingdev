class CreateRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :roles do |t|
      t.string :name
      t.integer :retailer_group_ids, array: true, :default => '{}'
      t.integer :city_ids, array: true, :default => '{}'
      t.timestamps

      add_column :admin_users, :role_id, :integer
    end
  end
end
