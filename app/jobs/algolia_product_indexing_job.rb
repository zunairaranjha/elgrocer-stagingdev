class AlgoliaProductIndexingJob < ActiveJob::Base
  queue_as :algolia_indexing

  def perform(product_ids)
    Product.products_to_algolia(product_ids: product_ids)
  end
end
