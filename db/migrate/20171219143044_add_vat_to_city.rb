class AddVatToCity < ActiveRecord::Migration
  def change
    add_column :cities, :vat, :integer, default: 5
  end
end
