class AddPriorityToRetailers < ActiveRecord::Migration
  def change
    add_column :retailers, :priority, :integer
  end
end
