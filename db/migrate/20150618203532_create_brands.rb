class CreateBrands < ActiveRecord::Migration
  def up
    drop_table :product_brands
    create_table :brands do |t|
      t.string :name
      t.timestamps null: false
    end
    rename_column :products, :product_brand_id, :brand_id
  end

  def down
    drop_table :brands
    create_table :product_brands do |t|
      t.string :name
    end
    rename_column :products, :brand_id, :product_brand_id
  end
end
