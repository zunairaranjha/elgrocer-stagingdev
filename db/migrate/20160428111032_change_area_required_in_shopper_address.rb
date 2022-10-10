class ChangeAreaRequiredInShopperAddress < ActiveRecord::Migration
  def change
    change_column :shopper_addresses, :area, :string, null: true
  end
end
