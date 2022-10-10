module DashboardService
  def self.execute_query(query)
    ActiveRecord::Base.connection.execute(query)
  end

  def self.avarage_basket_size
    average_query = 'SELECT avg(result.total_amount) FROM (SELECT sum(order_positions.amount) AS total_amount FROM order_positions GROUP BY order_positions.order_id ORDER BY total_amount DESC) AS result'

    average_results = execute_query(average_query)
    if average_results.any? && average_results.first['avg']
      average_results.first['avg']
    else
      "none"
    end
  end

  def self.top_basket_size
    top_query = "SELECT sum(order_positions.amount) AS total_amount, order_positions.order_id FROM order_positions GROUP BY order_positions.order_id ORDER BY total_amount DESC LIMIT 1"
    top_results = execute_query(top_query)
    top_results.any? ? top_results.first['total_amount'] : "none"
  end

  def self.bottom_basket_size
    bottom_query = "SELECT sum(order_positions.amount) AS total_amount, order_positions.order_id FROM order_positions GROUP BY order_positions.order_id ORDER BY total_amount ASC LIMIT 1"
    bottom_results = execute_query(bottom_query)
    bottom_results.any? ? bottom_results.first['total_amount'] : "none"
  end

  def self.avarage_basket_price
    average_query = 'SELECT avg(result.total_price) FROM (SELECT CAST (sum(order_positions.amount * (order_positions.shop_price_dollars + CAST( order_positions.shop_price_cents AS FLOAT)/100)) AS FLOAT) AS total_price FROM order_positions GROUP BY order_positions.order_id) AS result'

    average_results = execute_query(average_query)
    if average_results.any? && average_results.first['avg']
      average_results.first['avg']
    else
      "none"
    end
  end

  def self.top_basket_price
    top_query = "SELECT CAST (sum(order_positions.amount * (order_positions.shop_price_dollars + CAST( order_positions.shop_price_cents AS FLOAT)/100)) AS FLOAT) AS total_price FROM order_positions GROUP BY order_positions.order_id ORDER BY total_price DESC LIMIT 1"
    top_results = execute_query(top_query)
    top_results.any? ? top_results.first['total_price'] : "none"
  end

  def self.bottom_basket_price
    bottom_query = "SELECT CAST (sum(order_positions.amount * (order_positions.shop_price_dollars + CAST( order_positions.shop_price_cents AS FLOAT)/100)) AS FLOAT) AS total_price FROM order_positions GROUP BY order_positions.order_id ORDER BY total_price ASC LIMIT 1"
    bottom_results = execute_query(bottom_query)
    bottom_results.any? ? bottom_results.first['total_price'] : "none"
  end

  def self.top_10_retailers
    Retailer.top.limit(10)
  end

  def self.top_10_products
    Product.top.limit(10)
  end

  def self.total_number_of_products
    query = 'SELECT count(*) FROM (SELECT shops.product_id FROM shops GROUP BY shops.product_id ORDER BY shops.product_id DESC) AS result'
    result = execute_query(query)
    result.any? ? result.first['count'] : "none"
  end

  def self.total_income
    sum = 0
    op = OrderPosition.joins(:order).where({:orders => { :canceled_at => nil }})
    sum = op.sum('ROUND(ROUND(ROUND((order_positions.shop_price_dollars + (order_positions.shop_price_cents::numeric / 100)), 2) * order_positions.amount, 2) * order_positions.commission_value::numeric / 100, 2)')
    sum.round(2)
  end

  def self.current_month_total_income
    sum = 0
    op = OrderPosition.joins(:order).where("orders.created_at > '" + Date.today.beginning_of_month().to_s(:db) + "'").where({:orders => { :canceled_at => nil }})
    sum = op.sum('ROUND(ROUND(ROUND((order_positions.shop_price_dollars + (order_positions.shop_price_cents::numeric / 100)), 2) * order_positions.amount, 2) * order_positions.commission_value::numeric / 100, 2)')
    sum.round(2)
  end

  def self.total_income_for_period(date_from, date_to)
    sum = 0
    sql = ""
    sql += "orders.created_at >= '" + date_from + "' " unless date_from.blank?
    sql += "AND " unless date_to.blank?
    sql += "orders.created_at <= '" + date_to + "' " unless date_to.blank?
    op = OrderPosition.joins(:order).where(sql).where({:orders => { :canceled_at => nil }})
    sum = op.sum('ROUND(ROUND(ROUND((order_positions.shop_price_dollars + (order_positions.shop_price_cents::numeric / 100)), 2) * order_positions.amount, 2) * order_positions.commission_value::numeric / 100, 2)')
    sum.round(2)
  end

  def self.total_paid_from_wallet_for_period(date_from, date_to)
    sum = 0
    sql = ""
    sql += "orders.created_at >= '" + date_from + "' " unless date_from.blank?
    sql += "AND " unless date_to.blank?
    sql += "orders.created_at <= '" + date_to + "' " unless date_to.blank?
    op = Order.where(sql).where({:orders => { :canceled_at => nil }})
    sum = op.sum('ROUND(wallet_amount_paid)')
    sum.round(2)
  end

  def self.orders_count_for_period(date_from, date_to)
    sql = ""
    sql += "orders.created_at >= '" + date_from + "' " unless date_from.blank?
    sql += "AND " unless date_to.blank?
    sql += "orders.created_at <= '" + date_to + "' " unless date_to.blank?
    Order.where(sql).count
  end

  def self.get_all_categories
    Category.where('parent_id IS NULL')
  end
end
