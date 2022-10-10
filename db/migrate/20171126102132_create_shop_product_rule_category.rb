class CreateShopProductRuleCategory < ActiveRecord::Migration
  def change
    create_table :shop_product_rule_categories do |t|
      t.integer :shop_product_rule_id
      t.integer :category_id
    end
  end
end
