class ProductCategory < ActiveRecord::Base
  belongs_to :product, optional: true
  belongs_to :category, optional: true
end
