class AddImageUrlToProducts < ActiveRecord::Migration
  def up
    add_column :products, :image_external_url, :string
  end
  def down
    down_column :products, :image_external_url
  end
end
