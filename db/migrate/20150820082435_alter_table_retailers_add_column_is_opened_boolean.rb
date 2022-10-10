class AlterTableRetailersAddColumnIsOpenedBoolean < ActiveRecord::Migration
  def up
    add_column :retailers, :is_opened, :boolean, default: true
  end
  def down
    remove_column :retailers, :is_opened
  end
end
