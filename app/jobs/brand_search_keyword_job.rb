class BrandSearchKeywordJob
  @queue = :product_indexing_queue

  def self.perform(*args)
    product_ids = []
    BrandSearchKeyword.where(" date(end_date) = ?", (Time.now.to_date - 1.day)).pluck(:product_ids).each do |ids|
      product_ids.push(ids.split(',').map(&:to_i))
    end
    product_ids = product_ids.flatten
    Product.where(id: product_ids).update_all(search_keywords: "")
    Product.products_to_algolia(product_ids: product_ids)
  end
end

