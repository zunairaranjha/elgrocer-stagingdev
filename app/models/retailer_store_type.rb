class RetailerStoreType < ActiveRecord::Base
  belongs_to :store_type, optional: true
  belongs_to :retailer, optional: true
end