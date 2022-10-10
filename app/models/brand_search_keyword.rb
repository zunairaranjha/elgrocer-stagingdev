class BrandSearchKeyword < ActiveRecord::Base
  before_save :index_products

  def index_products
    product_ids_old = product_ids_was.to_s
    product_ids_new = product_ids.to_s
    product_ids = product_ids_old + "," + product_ids_new
    product_ids = product_ids.split(',').map(&:to_i).uniq
    AlgoliaProductIndexingJob.perform_later(product_ids)
  end
end
