class ShopperRecipe < ApplicationRecord
  belongs_to :shopper, optional: true
  belongs_to :recipe, optional: true
end
