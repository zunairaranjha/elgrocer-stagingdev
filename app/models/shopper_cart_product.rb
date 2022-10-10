class ShopperCartProduct < ActiveRecord::Base
  @queue = :default

  belongs_to :shopper, optional: true
  belongs_to :product, -> { unscope(:where) }, optional: true
  belongs_to :retailer, optional: true
  belongs_to :shop, -> { unscope(:where) }, optional: true
  belongs_to :shop_promotion, optional: true
  has_many :current_promotions, class_name: 'ShopPromotion', foreign_key: "product_id", primary_key: "product_id"

  def self.perform(params)
    # ShopperCartProduct.create params
    ::ShopperCartProducts::Create.run(params)
  end

end
