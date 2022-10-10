class AddIsPromotionalToProducts < ActiveRecord::Migration
  def change
    add_column :products, :is_promotional, :boolean, default: false
  end
end
