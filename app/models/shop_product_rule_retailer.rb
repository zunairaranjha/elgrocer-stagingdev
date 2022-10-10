class ShopProductRuleRetailer < ActiveRecord::Base
  belongs_to :shop_product_rule, optional: true
  belongs_to :retailer, optional: true
end
