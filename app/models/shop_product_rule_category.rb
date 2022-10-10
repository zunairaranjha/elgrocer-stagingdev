class ShopProductRuleCategory < ActiveRecord::Base
  belongs_to :shop_product_rule, optional: true
  belongs_to :category, optional: true
end
