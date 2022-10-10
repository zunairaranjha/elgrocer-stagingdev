class AddPriorityToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :priority, :integer
  end
end
