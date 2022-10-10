class AddShopperNoteToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shopper_note, :text
  end
end
