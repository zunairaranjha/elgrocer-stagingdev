class AddIsLocalToProduct < ActiveRecord::Migration
  def change
    add_column :products, :is_local, :bool
  end
end
