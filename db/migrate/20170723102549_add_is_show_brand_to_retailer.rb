class AddIsShowBrandToRetailer < ActiveRecord::Migration
  def change
    add_column :retailers, :is_show_brand, :boolean, default: true
  end
end
