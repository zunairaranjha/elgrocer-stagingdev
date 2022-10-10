class ShopProductRule < ActiveRecord::Base
  has_many :shop_product_rule_categories
  has_many :categories, through: :shop_product_rule_categories, source: :category
  has_many :shop_product_logs, as: :owner
  has_many :shop_product_rule_retailers
  has_many :retailers, through: :shop_product_rule_retailers, source: :retailer
end
