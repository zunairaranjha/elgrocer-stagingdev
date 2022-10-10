class AddIsShowBrandToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :is_show_brand, :boolean, default: true
  end
end
