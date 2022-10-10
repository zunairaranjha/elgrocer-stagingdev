class Retailers::ShowProducts < Retailers::Base
  integer :retailer_id
  integer :brand_id, default: nil
  integer :category_id, default: nil
  integer :limit, default: nil
  integer :offset, default: nil

  validate :retailer_exists

  def execute
    products
  end

  private

  def retailer
    @retailer ||= Retailer.joins(:products).find_by(id: retailer_id)
  end

  def products
    if brand_id && category_id
      retailer_products_count = retailer.products.joins(:product_categories).where({brand_id: brand_id, product_categories: {category_id: category_id}}).count
      retailer_products = retailer.products.joins(:product_categories).where({brand_id: brand_id, product_categories: {category_id: category_id}}).limit(limit).offset(offset)
    elsif brand_id
      retailer_products_count = retailer.products.where(brand_id: brand_id).count
      retailer_products = retailer.products.where(brand_id: brand_id).limit(limit).offset(offset)
    elsif category_id
      retailer_products_count = retailer.products.joins(:product_categories).where(product_categories: {category_id: category_id}).count
      retailer_products = retailer.products.joins(:product_categories).where(product_categories: {category_id: category_id}).limit(limit).offset(offset)
    else
      retailer_products_count = retailer.products.count
      retailer_products = retailer.products.limit(limit).offset(offset)
    end
    
    retailer_products = retailer_products.order('shops.product_rank desc, shops.product_id desc')

    if (limit.present? && offset.present?)
      is_next = (limit + offset < retailer_products_count)
    else
      is_next = false
    end
    [is_next, retailer_products]
  end

end
