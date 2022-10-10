class AddAppVersionToOrdersShoppers < ActiveRecord::Migration
  def change
    add_column :orders, :app_version, :string
    add_column :shoppers, :app_version, :string
  end
end
