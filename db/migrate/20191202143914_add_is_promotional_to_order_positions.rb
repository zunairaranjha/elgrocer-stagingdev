class AddIsPromotionalToOrderPositions < ActiveRecord::Migration
  def change
    add_column :order_positions, :is_promotional, :boolean, default: false
  end
end
