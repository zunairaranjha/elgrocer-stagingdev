class CreateRolePermissions < ActiveRecord::Migration[5.1]
  def change
    create_table :role_permissions do |t|
      t.references :role, index: true
      t.references :permission, index: true
      # t.integer :permission_id, index: true
      t.string :can_create, default: ""
      t.string :can_read, default: ""
      t.string :can_update, default: ""
      t.string :can_delete, default: ""
      
      t.timestamps
    end
    add_column :permissions, :parent_id, :integer, :null => true, :index => true
    add_foreign_key :role_permissions, :roles
    add_foreign_key :role_permissions, :permissions
  end
end
