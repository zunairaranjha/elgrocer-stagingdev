class AddFieldsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :shelf_life, :integer
    add_column :products, :size_unit, :string
  end
end
