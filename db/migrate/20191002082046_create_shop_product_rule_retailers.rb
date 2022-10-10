class CreateShopProductRuleRetailers < ActiveRecord::Migration
  def change
    create_table :shop_product_rule_retailers, id: false do |t|
      t.integer :shop_product_rule_id
      t.integer :retailer_id
    end
  end
end
