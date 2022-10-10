class RemoveNeedlessAdressFields < ActiveRecord::Migration
  def change
    remove_column :shopper_addresses, :city
    remove_column :shopper_addresses, :floor_number
  end
end
