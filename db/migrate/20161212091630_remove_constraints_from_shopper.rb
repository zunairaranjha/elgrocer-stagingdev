class RemoveConstraintsFromShopper < ActiveRecord::Migration
  def change
    change_column :shoppers, :name, :string, :null => true
    change_column :shoppers, :phone_number, :string, :null => true
  end
end
