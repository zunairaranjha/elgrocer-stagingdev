class AddFieldsToProduct < ActiveRecord::Migration
  def up
    add_column :products, :name, :string
    add_column :products, :description, :string
    add_attachment :products, :photo
  end

  def down
    remove_column :products, :name
    remove_column :products, :description
    remove_attachment :products, :photo
  end
end
