class ProductSuggestion < ActiveRecord::Base
  belongs_to :retailer, optional: true
  belongs_to :shopper, optional: true
end
