class AddProductsLimitToDeliverySlot < ActiveRecord::Migration
  def change
    add_column :delivery_slots, :products_limit, :integer, default: 0
    add_column :delivery_slots, :products_limit_margin, :integer, default: 0
  end
end
