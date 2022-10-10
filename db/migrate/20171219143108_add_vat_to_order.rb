class AddVatToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :vat, :integer, default: 0
  end
end
