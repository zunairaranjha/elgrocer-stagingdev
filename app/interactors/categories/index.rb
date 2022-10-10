class Categories::Index < Categories::Base

  def execute
    get_populated_categories
  end

  private

  def get_populated_categories
    products_ids = Shop.uniq.pluck(:product_id)
    products = Product.find(products_ids)
    products.each do |prod|

    end
  end

end