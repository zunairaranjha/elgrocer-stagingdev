class CreateShopProductRules < ActiveRecord::Migration
  def change
    create_table :shop_product_rules do |t|
      t.integer :at_day
      t.string  :at_time
      # t.string :category_ids
      t.boolean  :is_enable, default: true

      t.timestamps null: false
    end
  end
end
