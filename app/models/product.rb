class Product < ActiveRecord::Base
  # include ProductIndexing
  # include CollectionSearchable
  include AlgoliaProductIndexing
  extend FriendlyId
  friendly_id :slug_candidates, use: %i[finders slugged]

  validates :barcode, uniqueness: { case_sensitive: false }

  @retailer_of_product = 0

  class << self
    attr_accessor :retailer_of_product
  end

  default_scope -> { where('products.photo_file_size IS NOT NULL') }
  scope :without_photo, -> { where('products.photo_file_size IS NULL') }
  scope :with_photo, -> { where('products.photo_file_size IS NOT NULL') }
  scope :without_brand, -> { where('products.brand_id IS NULL') }
  # scope :top_selling, -> (from_date){ select('products.*, SUM(order_positions.amount) as total_qty, count(order_positions.amount) as total_count, SUM(order_positions.amount * round(order_positions.shop_price_dollars + order_positions.shop_price_cents/100.0, 2)) as total_amount').joins(:shops, :categories).joins("LEFT JOIN orders ON orders.retailer_id = shops.retailer_id AND date(orders.created_at) >= '#{from_date}'").joins("LEFT JOIN order_positions ON order_positions.shop_id = shops.id AND order_positions.order_id = orders.id").group('products.id').order('total_count desc', 'products.id') }
  scope :top_selling, lambda { |days, retailer_id, shopper_id|
    opstr = shopper_id ? '' : "AND order_positions.order_id in (select id from orders where date(orders.created_at) >= '#{days.day.ago.to_date}' and retailer_id = #{retailer_id})"
    products = select('products.*, SUM(order_positions.amount) as total_qty, count(order_positions.amount) as total_count, SUM(order_positions.amount * round(order_positions.shop_price_dollars + order_positions.shop_price_cents/100.0, 2)) as total_amount, shops.price_currency,shops.price_dollars,shops.price_cents,shops.is_available,shops.is_published')
    products = products.joins(:shops, :categories).joins("LEFT JOIN order_positions ON order_positions.shop_id = shops.id #{opstr}")
    # products = products.where("order_positions.order_id is null or order_positions.order_id in (?)", Order.where("date(orders.created_at) >= ? and retailer_id = ?", days.day.ago.to_date, retailer_id).ids) unless shopper_id
    products = products.group('products.id,shops.id').order('total_count desc', 'products.id') }
  # scope :promotional, -> { where(is_promotional: true) }
  scope :select_info, -> { select('products.*, shops.price_currency, shops.price_dollars + shops.price_cents/100.0 AS price, shops.is_available, shops.is_published, shops.product_rank, shops.updated_at, shops.retailer_id, shops.promotion_only, shops.id AS shop_id, shops.available_for_sale') }

  belongs_to :brand, optional: true
  belongs_to :location, optional: true
  has_many :product_categories
  has_many :shops
  has_many :shop_join_retailers
  has_many :unscoped_shops, -> { unscope(where: %i[is_available is_published]) }, class_name: 'Shop'
  has_many :retailer_shops, -> { where(retailer_id: Product.retailer_of_product) }, class_name: 'Shop'
  has_many :retailers, through: :shops
  has_many :order_positions
  has_many :order_substitutions
  belongs_to :category_parent, optional: true, class_name: 'Category', foreign_key: 'category_parent_id'
  has_many :subcategories, through: :product_categories, source: :category
  has_many :categories, through: :subcategories, source: :parent
  has_many :screen_products
  # has_many :shopper_favourite_products
  # has_many :patrons, class_name: "Shopper", through: :shopper_favourite_products
  has_many :retailer_shop_promotions, -> { where(retailer_id: Product.retailer_of_product) }, class_name: 'ShopPromotion'
  has_many :algolia_shop_promotions, lambda {
    where("start_time <= #{((Time.now + (Redis.current.get('promotion_index_hours') || SystemConfiguration.find_by(key: 'promotion_index_hours')&.value).to_i.hours).utc.to_f * 1000).floor} AND end_time > #{(Time.now.utc.to_f * 1000).floor}")
      .order(:end_time, :start_time)
  }, class_name: 'ShopPromotion'
  has_many :shop_promotions # , -> { where(retailer_id: Product.retailer_of_product) }

  # after_commit on: [:create] do
  #  Resque.enqueue(Indexer, :create, self.class.name, id)
  # end
  #
  # after_commit on: [:update] do
  #  Resque.enqueue(Indexer, :update, self.class.name, id)
  #  # shops.each do |s|
  #  #   Resque.enqueue(Indexer, :update, s.class.name, s.id)
  #  # end
  #  # Shop.bulk_index(shops)
  #  Resque.enqueue(Indexer, :bulk_index, self.class.name, self.id)
  # end

  # def bulk_index
  #  shops.find_in_batches do |bshops|
  #    Shop.bulk_index(bshops)
  #  end
  # end

  # after_commit on: [:destroy] do
  #  Resque.enqueue(Indexer, :delete, self.class.name, id)
  #  shops.each do |s|
  #    Resque.enqueue(Indexer, :delete, s.class.name, s.id)
  #  end
  # end

  scope :top, lambda {
    select('products.id, products.name, products.name_ar, count(order_positions.id) AS orders_count').
      joins(:order_positions).
      group('products.id').
      order('orders_count DESC')
  }

  def self.ransackable_scopes(_opts)
    [:barcode_includes]
  end

  scope :barcode_includes, lambda { |search|
    current_scope = self
    current_scope = current_scope.where(barcode: search.split(','))
    current_scope
  }

  attr_accessor :in_shop, :current_retailer

  has_attached_file :photo, styles: { medium: '300x300>', icon: '50x50#' }, default_url: 'https://api.elgrocer.com/images/:style/missing.png'
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\Z/

  def slug_candidates
    [:name, %i[name size_unit], %i[name size_unit id], randomize_slug]
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def to_param
    id.to_s
  end

  def full_name
    "#{id} : #{name} : #{size_unit}"
  end

  def name
    if I18n.locale == :ar
      value = self.send("name_#{I18n.locale.to_s}")
    end
    value || read_attribute(:name)
  end

  def description
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.send("description_#{I18n.locale.to_s}")
    end
    value || read_attribute(:description)
  end

  def size_unit
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.send("size_unit_#{I18n.locale.to_s}")
    end
    value || read_attribute(:size_unit)
  end

  def photo_from_url(url)
    self.photo = open(url)
  end

  def brand_hash
    brand ? { name: brand.name, name_ar: brand.name_ar, id: brand.id, slug: brand.slug, image_url: brand.photo_url, logo1_url: brand.logo1_url, logo2_url: brand.logo2_url } : nil
  end

  def brands
    brand ? { name: brand.name, name_ar: brand.name_ar, id: brand.id, image_url: brand.photo_url, slug: brand.slug } : nil
  end

  def brand_name
    brand ? brand.name : 'Other'
  end

  def photo_url
    photo ? photo.url(:medium) : nil
  end

  def small_photo_url
    photo ? photo.url(:medium) : nil
  end

  def icon_url
    photo ? photo.url(:icon) : nil
  end

  def add_brand(name)
    brand = Brand.find_by({ name: name })
    brand ||= Brand.create({ name: name })
    self.brand = brand
    self.save

  end

  def add_category(subcategory_id)
    product_categories.clear
    ProductCategory.create!(product_id: self.id, category_id: subcategory_id)

  end

  def add_to_shop(retailer_id, price_cents, price_dollars, detail)
    retailer_add_to_shop(retailer_id, price_cents, price_dollars, detail)
  end

  def retailer_add_to_shop(retailer_id, price_cents, price_dollars, detail)
    shop = get_shop(retailer_id)
    return self unless shop

    shop.price_cents = price_cents
    shop.price_dollars = price_dollars
    shop.is_available = true
    if shop.changed?
      shop.detail.merge!(detail)
      shop.save rescue ''
    end
    self
  end

  def add_to_shop_raw(retailer_id, price_cents, price_dollars, is_promotional: false, is_published: true, detail: {}, promotion_only: false, promo_updated: false, price_currency: 'AED', enabling_disabled: false)
    # self.current_retailer = Retailer.find retailer_id
    # retailer_id = retailer_id.to_i
    # _params = {
    #   retailer_id: retailer_id,
    #   price_cents: price_cents,
    #   price_dollars: price_dollars,
    #   price_currency: 'AED',
    #   product_id: self.id,
    #   is_available: true,
    #   is_published: is_published,
    # }
    # _params[:detail] = {"owner" => owner}
    # _params[:is_promotional] = is_promotional unless is_promotional.nil?

    # shop = Shop.unscoped.find_by({retailer_id: retailer_id, product_id: self.id})
    # if shop
    #   _params[:detail] = _params[:detail].merge(shop.detail)
    #   shop.update(_params) rescue ''
    # else
    #   Shop.create(_params) rescue ''
    # end
    shop = get_shop(retailer_id, enabling_disabled: enabling_disabled)
    return shop unless shop

    shop.price_cents = price_cents
    shop.price_dollars = price_dollars
    shop.price_currency = price_currency
    shop.promotion_only = promotion_only
    shop.is_available = true
    shop.is_published = is_published
    shop.is_promotional = is_promotional
    shop.detail.delete('permanently_disabled') if enabling_disabled
    if shop.changed? || promo_updated
      ShopPromotion.where(retailer_id: retailer_id, product_id: self.id, is_active: true).update_all(is_active: false) unless shop.is_promotional
      shop.detail.merge!(detail)
      shop.save rescue ''
      return true
    end
    false
  end

  def add_shop_promotion(retailer_id, standard_price, price, start_time, end_time, product_limit, price_currency)
    shop_promotion = ShopPromotion.find_or_initialize_by(retailer_id: retailer_id, product_id: self.id, price_currency: price_currency)
    shop_promotion.standard_price = standard_price
    shop_promotion.price = price
    shop_promotion.start_time = (start_time.to_time.utc.to_f * 1000).floor
    shop_promotion.end_time = (end_time.to_time.utc.to_f * 1000).floor
    shop_promotion.product_limit = product_limit
    if shop_promotion.changed?
      if shop_promotion.persisted?
        shop_promotion.updated_at = Time.now
        shop_promotion.update_columns(shop_promotion.attributes.except('id', 'retailer_id', 'product_id')) rescue ''
      else
        ShopPromotion.import [shop_promotion] rescue ''
      end
      return true
    end
    false
  end

  def remove_from_shop(retailer_id)
    shop = Shop.unscoped.find_by({ retailer_id: retailer_id, product_id: self.id })
    shop&.destroy!
  end

  def update_country(alpha2)
    if Country[alpha2]
      self.country_alpha2 = alpha2
      self.save
    end
  end

  def get_shop(retailer_id, enabling_disabled: false)
    shop = Shop.unscoped.find_or_initialize_by({ retailer_id: retailer_id, product_id: id })
    if (!enabling_disabled && shop.detail['permanently_disabled'].to_i.positive?) || (shop.detail['last_inactive_time'] && shop.detail['last_inactive_time'].to_time > (Time.now - 1.day).utc)
      false
    else
      shop
    end
  end

  def self.products_with_shops(product_ids, retailer_id, delivery_time, previously_purchased = nil)
    products = Product.joins(:shops).select('products.*, shops.id AS shop_id, shops.price_cents, shops.price_dollars, shops.price_currency, shops.promotion_only, shops.available_for_sale, shops.is_available, shops.is_published')
    sql1 = products.where(id: product_ids, shops: { retailer_id: retailer_id, promotion_only: false }).to_sql
    products = Product.joins(:shop_promotions, :shops).select('products.*, shops.id AS shop_id, shops.price_cents, shops.price_dollars, shops.price_currency, shops.promotion_only, shops.available_for_sale, shops.is_available, shops.is_published')
    products = products.where(id: product_ids, shops: { retailer_id: retailer_id, is_promotional: true, promotion_only: true })
    sql2 = products.where('shop_promotions.retailer_id = ? AND ? BETWEEN shop_promotions.start_time AND shop_promotions.end_time', retailer_id, delivery_time).to_sql
    list_of_products = Product.find_by_sql("(#{sql1}) UNION (#{sql2})")
    unless previously_purchased.blank?
      previous_list = Product.products_with_unscoped_shops(previously_purchased, retailer_id, delivery_time)
      list_of_products |= previous_list
    end
    list_of_products
  end

  def self.products_with_unscoped_shops(product_ids, retailer_id, delivery_time)
    products = Product.joins(:unscoped_shops).select('products.*, shops.id AS shop_id, shops.price_cents, shops.price_dollars, shops.price_currency, shops.promotion_only, shops.available_for_sale, shops.is_available, shops.is_published')
    sql1 = products.where(id: product_ids, shops: { retailer_id: retailer_id, promotion_only: false }).to_sql
    products = Product.joins(:shop_promotions, :unscoped_shops).select('products.*, shops.id AS shop_id, shops.price_cents, shops.price_dollars, shops.price_currency, shops.promotion_only, shops.available_for_sale, shops.is_available, shops.is_published')
    products = products.where(id: product_ids, shops: { retailer_id: retailer_id, is_promotional: true, promotion_only: true })
    sql2 = products.where('shop_promotions.retailer_id = ? AND ? BETWEEN shop_promotions.start_time AND shop_promotions.end_time', retailer_id, delivery_time).to_sql
    Product.find_by_sql("(#{sql1}) UNION (#{sql2})")
  end

  def create_from_base
    datakick = Datakick.new
    item = datakick.item(self.barcode)
    if item
      if item.images != []
        self.photo_from_url item.images[0].url
      end
      self.name = item.name
      self.size_unit = item['size']
      self.add_brand(item.brand_name)
      self.save
    end
  end

  # def self.import
  #  Product.includes(:brand, categories: :subcategories).find_in_batches do |product|
  #    bulk_index(product)
  #  end
  # end
  #
  # def self.prepare_records(products)
  #  products.map do |product|
  #    { index: { _id: product.id, data: product.as_indexed_json } }
  #  end
  # end

  # def self.bulk_index(products)
  #  Product.__elasticsearch__.client.bulk({
  #    index: ::Product.__elasticsearch__.index_name,
  #    type: ::Product.__elasticsearch__.document_type,
  #    body: prepare_records(products)
  #  })
  # end

  # def shop(retailer)
  #   @shop ||= Shop.unscoped.where({product_id: self.id,retailer: retailer}).first
  # end

  # def in_shop(retailer)
  #   shop(retailer).present? ? true : false
  #   # Shop.exists?({product_id: self.id, retailer: retailer})
  # end

  # def shop_id(retailer)
  #   shop(retailer).present? ? shop(retailer).id : ""
  # end

  # def is_published(retailer)
  #   shop(retailer).present? ? shop(retailer).is_published : ""
  # end

  # def is_available(retailer)
  #   shop(retailer).present? ? shop(retailer).is_available : ""
  # end

  def category_name
    category = Category.find_by_sql('SELECT c.name FROM products AS p INNER JOIN product_categories AS pc ON pc.product_id = p.id INNER JOIN categories AS sc ON pc.category_id = sc.id INNER JOIN categories AS c ON sc.parent_id = c.id WHERE p.id = %{product_id}' % { product_id: self.id })
    category.size.positive? ? category[0]['name'] : 'Other'
  end

  def subcategory_name
    subcategory = Category.find_by_sql('SELECT sc.name FROM products AS p INNER JOIN product_categories AS pc ON pc.product_id = p.id INNER JOIN categories AS sc ON pc.category_id = sc.id INNER JOIN categories AS c ON sc.parent_id = c.id WHERE p.id = %{product_id}' % { product_id: self.id })
    subcategory.size.positive? ? subcategory[0]['name'] : 'Other'
  end

  def as_indexed_json(*)
    product_attrs = product_attrs_hash

    product_attrs[:categories] = categories.map do |cat|
      result = {
        id: cat.id,
        name: cat.name,
        name_ar: cat.name_ar,
        image_url: cat.photo_url
      }

      result[:children] = subcategories.map do |child|
        # result_child = nil
        # if subcategories.include? child
        result_child = {
          id: child.id,
          name: child.name,
          name_ar: child.name_ar,
          image_url: child.photo_url
        }
        # end
        # result_child
      end
      # result[:children].reject! { |c| c.blank? }
      result
    end
    product_attrs.as_json
  end

  def self.products_to_algolia(product_ids: nil)
    Product.where('products.photo_file_size IS NOT NULL AND products.name is not null AND products.id in (?)', product_ids).includes(:category_parent, :brand, :shop_join_retailers, :categories, :subcategories, :algolia_shop_promotions).reindex!
  end

  def product_attrs_hash
    {
      id: id,
      name: name,
      name_ar: name_ar,
      category_name: categories.map(&:name),
      category_name_ar: categories.map(&:name_ar),
      subcategory_name: subcategories.map(&:name),
      subcategory_name_ar: subcategories.map(&:name_ar),
      brand_name: brand.try(:name),
      brand_name_ar: brand.try(:name_ar),
      barcode: barcode,
      brand: brand_hash,
      description: description,
      description_ar: description_ar,
      search_keywords: search_keywords,
      image_url: small_photo_url,
      full_image_url: photo_url,
      shelf_life: shelf_life,
      size_unit: size_unit,
      is_local: is_local
      # country: Country[country_alpha2] ? {alpha2: Country[country_alpha2].alpha2, name: Country[country_alpha2].name } : nil
    }
  end

  def self.sponsored_ids
    @product_ids ||= BrandSearchKeyword.where(' ? between date(start_date) and date(end_date)', Time.now.to_date).pluck(:product_ids).to_s.scan(/\d+/)
  end

  private

  def randomize_slug
    begin
      new_slug = "#{self.name}-#{SecureRandom.random_number(999999).to_s}"
    end while Product.where(slug: new_slug).exists?
    new_slug
  end

end
