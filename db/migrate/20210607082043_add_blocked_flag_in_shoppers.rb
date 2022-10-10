class AddBlockedFlagInShoppers < ActiveRecord::Migration[5.1]
  def change
    add_column :shoppers, :is_blocked, :boolean, :default => false
  end
end
