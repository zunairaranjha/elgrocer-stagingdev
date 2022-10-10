class AddTokenToShoppers < ActiveRecord::Migration
  def up
    add_column :shoppers, :authentication_token, :string

    add_index :shoppers, :authentication_token, unique: true
  end
  def down
    drop_column :shoppers, :authentication_token

    drop_index :shoppers, :authentication_token
  end
end
