namespace :shops do
  desc 'It generate and assign product ranks based on orders (last 30 days)'
  task update_product_rank: :environment do
    days_from = ENV['days_from'] || 1
    days_to = ENV['days_to'] || 1
    days_from = days_from.to_i
    days_to = days_to.to_i

    ActiveRecord::Base.connection.execute("UPDATE shops SET product_rank = product_rank + ops.sale
        FROM (SELECT o.retailer_id, op.product_id, SUM(amount) AS sale FROM order_positions op, orders o WHERE o.id = op.order_id AND DATE(o.created_at) BETWEEN DATE(now() - '#{days_from}day'::interval) AND DATE(now() - '#{days_to}day'::interval) GROUP BY o.retailer_id, op.product_id) AS ops
        WHERE shops.product_id = ops.product_id AND shops.retailer_id = ops.retailer_id") rescue ''

    ActiveRecord::Base.connection.execute("UPDATE categories SET sale_rank = sale_rank + ops.sale
        FROM (SELECT pc.category_id, SUM(amount) AS sale FROM order_positions op, orders o, product_categories pc WHERE o.id = op.order_id AND pc.product_id = op.product_id AND DATE(o.created_at) BETWEEN DATE(now() - '#{days_from}day'::interval) AND DATE(now() - '#{days_to}day'::interval) GROUP BY pc.category_id) AS ops
        WHERE categories.id = ops.category_id") rescue ''

    ActiveRecord::Base.connection.execute("UPDATE products SET sale_rank = sale_rank + ops.sale
        FROM (SELECT op.product_id, SUM(amount) AS sale FROM order_positions op, orders o WHERE o.id = op.order_id AND DATE(o.created_at) BETWEEN DATE(now() - '#{days_from}day'::interval) AND DATE(now() - '#{days_to}day'::interval) GROUP BY op.product_id) AS ops
        WHERE products.id = ops.product_id") rescue ''

    #///////////////// To Index on Algolia
    category_ids = Category.joins(:product_categories).joins("INNER JOIN order_positions op ON op.product_id = product_categories.product_id").joins("INNER JOIN orders ON orders.id = op.order_id AND DATE(orders.created_at) BETWEEN DATE(now() - '#{days_from}day'::interval) AND DATE(now() - '#{days_to}day'::interval)")
                       .group("categories.id").pluck("categories.id")
    index_rank(category_ids)


    # City.all.each do |city|
    # if settings.product_rank_date
    # product_rank_days = Setting.pluck(:product_rank_days).to_i || 30
    # order_positions = OrderPosition.where(order_id: Order.where("date(created_at) >= '#{product_rank_days.day.ago.to_date}'").where(retailer_id: Retailer.where(location_id: city.locations)))
    # orders = Order.where("created_at > '#{settings.product_rank_date.iso8601(10)}'").order(:created_at).limit(settings.product_rank_orders_limit || 5)
    # settings.update_columns(product_rank_date: orders.last.created_at) if orders.any?
      # order_positions = OrderPosition.where(order_id: orders)
      # .select(:product_id, 'sum(order_positions.amount) quantity,sum(ROUND(ROUND((order_positions.shop_price_dollars + (order_positions.shop_price_cents::numeric / 100)), 2) * order_positions.amount, 2)) price')
      # .group(:product_id)
      # order_positions.each do |posi|
      #   shops = Shop.where(product_id: posi.product_id).where(retailer_id: Retailer.where(location_id: posi.order.retailer.location.city.locations))
      #   next if shops.first.blank? # continue if no entries in shops
      #   new_rank = shops.first.product_rank.to_f + posi.amount / 100.0
      #   shops.update_all(product_rank: new_rank.round(2))
        # shops.each do |shop|
        #   shop.__elasticsearch__.update_document_attributes product_rank: shop.product_rank.to_f
        #   Resque.enqueue(Indexer, :update_rank, shop.class.name, shop.id)
        #   # shop.__elasticsearch__.update_document_attributes {product_rank: shop.product_rank.to_f, upsert: {product_rank: shop.product_rank.to_f }}
        #   # shop.__elasticsearch__.update_document upsert: {product_rank: shop.product_rank.to_f }
        #   # shop.__elasticsearch__.update_document({doc_as_upsert: true})
        #   # shop.__elasticsearch__.update_document
        # end
      # end
    # end
  end

  task update_product_derank: :environment do
    days_from = ENV['days_from'] || 30
    days_to = ENV['days_to'] || 30
    days_from = days_from.to_i
    days_to = days_to.to_i

    ActiveRecord::Base.connection.execute("UPDATE shops SET product_rank = product_rank - ops.sale
        FROM (SELECT o.retailer_id, op.product_id, SUM(amount) AS sale FROM order_positions op, orders o WHERE o.id = op.order_id AND DATE(o.created_at) BETWEEN DATE(now() - '#{days_from}day'::interval) AND DATE(now() - '#{days_to}day'::interval) GROUP BY o.retailer_id, op.product_id) AS ops
        WHERE shops.product_id = ops.product_id AND shops.retailer_id = ops.retailer_id") rescue ''

    ActiveRecord::Base.connection.execute("UPDATE categories SET sale_rank = sale_rank - ops.sale
        FROM (SELECT pc.category_id, SUM(amount) AS sale FROM order_positions op, orders o, product_categories pc WHERE o.id = op.order_id AND pc.product_id = op.product_id AND DATE(o.created_at) BETWEEN DATE(now() - '#{days_from}day'::interval) AND DATE(now() - '#{days_to}day'::interval) GROUP BY pc.category_id) AS ops
        WHERE categories.id = ops.category_id") rescue ''

    ActiveRecord::Base.connection.execute("UPDATE products SET sale_rank = sale_rank - ops.sale
        FROM (SELECT op.product_id, SUM(amount) AS sale FROM order_positions op, orders o WHERE o.id = op.order_id AND DATE(o.created_at) BETWEEN DATE(now() - '#{days_from}day'::interval) AND DATE(now() - '#{days_to}day'::interval) GROUP BY op.product_id) AS ops
        WHERE products.id = ops.product_id") rescue ''

    #///////// To Index Algolia
    # category_ids = Category.joins(:product_categories).joins("INNER JOIN order_positions op ON op.product_id = product_categories.product_id").joins("INNER JOIN orders ON orders.id = op.order_id AND DATE(orders.created_at) BETWEEN DATE(now() - '#{days_from}day'::interval) AND DATE(now() - '#{days_to}day'::interval)")
    #                    .group("categories.id").pluck("categories.id")
    # index_rank(category_ids)
    # /////////////// To save requests we have commented this

    # if settings.product_derank_date
    #   orders = Order.where("created_at > '#{settings.product_derank_date.iso8601(10)}' and date(created_at) < '#{settings.product_rank_days.day.ago.to_date}'").order(:created_at).limit(settings.product_rank_orders_limit || 5)
    #   settings.update_columns(product_derank_date: orders.last.created_at) if orders.any?
      # order_positions = OrderPosition.where(order_id: orders)
      # order_positions.each do |posi|
      #   shops = Shop.where(product_id: posi.product_id).where(retailer_id: Retailer.where(location_id: posi.order.retailer.location.city.locations))
      #   next if shops.first.blank? # continue if no entries in shops
      #   new_rank = shops.first.product_rank.to_f - posi.amount / 100.0
      #   new_rank = new_rank < 0 ? 0 : new_rank # keep it zero if -ve
      #   shops.update_all(product_rank: new_rank.round(2))
        # shops.each do |shop|
        #   Resque.enqueue(Indexer, :update_rank, shop.class.name, shop.id)
        # end
      # end
    # end
  end

  def index_rank(category_ids)
    # bulk update rank on Algolia
    Product.includes(:category_parent, :brand, :shop_join_retailers, :categories, :subcategories, :algolia_shop_promotions).joins(:product_categories).where(product_categories: {category_id: category_ids}).where("products.photo_file_size IS NOT NULL AND products.name is not null").reindex!
    # bulk update rank on ES
    #Shop.__elasticsearch__.client.bulk({
    #  index: ::Shop.__elasticsearch__.index_name,
    #  type: ::Shop.__elasticsearch__.document_type,
    #  body: shops.map do |shop|
    #    { update: { _id: shop.id, data: {doc: { product_rank: new_rank }} } }
    #  end
    #})
  end

  def settings
    @settings ||= Setting.first
  end
end
