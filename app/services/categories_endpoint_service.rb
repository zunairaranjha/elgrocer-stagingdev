module CategoriesEndpointService

  def self.result(params)
    retailer_id = params[:retailer_id]
    parent_id = params[:parent_id]

    # categories
    if retailer_id
      @category_sql = "
        SELECT DISTINCT (c.id) FROM categories AS c
          INNER JOIN categories AS sc ON c.id = sc.parent_id
          INNER JOIN product_categories AS pc ON pc.category_id = sc.id
          INNER JOIN products AS p ON p.id = pc.product_id
          INNER JOIN brands AS b ON b.id = p.brand_id
          INNER JOIN shops AS s ON p.id = s.product_id WHERE s.retailer_id = #{retailer_id}"
      @subcategory_sql = "
        SELECT DISTINCT (sc.id) FROM categories AS c
          INNER JOIN categories AS sc ON c.id = sc.parent_id
          INNER JOIN product_categories AS pc ON pc.category_id = sc.id
          INNER JOIN products AS p ON p.id = pc.product_id
          INNER JOIN brands AS b ON b.id = p.brand_id
          INNER JOIN shops AS s ON p.id = s.product_id
          WHERE s.retailer_id = #{retailer_id} AND sc.parent_id= #{parent_id}" if parent_id
    else
      @category_sql = "SELECT DISTINCT (c.id) FROM categories AS c
        INNER JOIN categories AS sc ON c.id = sc.parent_id
        INNER JOIN product_categories AS pc ON pc.category_id = sc.id
        INNER JOIN products AS p ON p.id = pc.product_id
        INNER JOIN brands AS b ON b.id = p.brand_id
        INNER JOIN shops AS s ON p.id = s.product_id"

      @subcategory_sql = "SELECT DISTINCT (sc.id) FROM categories AS c
        INNER JOIN categories AS sc ON c.id = sc.parent_id
        INNER JOIN product_categories AS pc ON pc.category_id = sc.id
        INNER JOIN products AS p ON p.id = pc.product_id
        INNER JOIN brands AS b ON b.id = p.brand_id
        INNER JOIN shops AS s ON p.id = s.product_id
        WHERE sc.parent_id= #{parent_id}" if parent_id
    end
    # subcategories (for a category): #{self.sender.name}
    if params['limit'].present? && params['offset'].present?
      @is_next = params['limit'] + params['offset'] < Category.where(parent_id: parent_id).count
    else
      @is_next = false
    end
    categories = set_categories(retailer_id, parent_id, params)
    { :next => @is_next, categories: categories }
  end

  private

  def self.set_categories(retailer_id, parent_id, params)
    if parent_id
      categories = Category.joins(:brands)
      categories = categories.where("categories.id in (#{@subcategory_sql})") if retailer_id
    else
      categories = Category.includes(:subcategories).where("categories.id in (#{@category_sql})")
    end

    categories = categories.where(parent_id: parent_id) if parent_id
    if params['limit'].present? && params['offset'].present?
      categories = categories.limit(params['limit']).offset(params['offset']).order(:priority).distinct
    else
      categories = categories.order(:priority).distinct
    end
    categories
  end
end
