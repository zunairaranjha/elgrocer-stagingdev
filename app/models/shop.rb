class Shop < ActiveRecord::Base
  @queue = :default
  # include ShopIndexing
  # include CollectionSearchable

  belongs_to :retailer, optional: true
  belongs_to :product, optional: true, touch: true
  has_one :brand, through: :product
  has_many :product_categories, through: :product
  has_many :subcategories, through: :product_categories, source: :category
  has_many :categories, through: :subcategories, source: :parent
  has_many :order_positions
  has_many :shop_promotions, ->(shop) { where(retailer_id: shop.retailer_id) }, foreign_key: 'product_id', primary_key: 'product_id'
  accepts_nested_attributes_for :shop_promotions, allow_destroy: false
  # has_many :subcategories, class_name: "Category", through: :product_categories
  # has_many :categories, through: :subcategories, foreign_key: "parent_id"
  register_currency :aed

  default_scope -> { where(is_published: true, is_available: true).not_oos }
  scope :published, -> { where(is_published: true) }
  scope :unpublished, -> { where(is_published: false) }
  scope :available, -> { where(is_available: true) }
  scope :unavailable, -> { where(is_available: false) }
  scope :particular_commission_value, -> { where('shops.commission_value IS NOT NULL') }
  scope :promotional, -> { where(is_promotional: true) }
  scope :not_oos, -> { where("(#{self.table_name}.detail->>'last_inactive_time' IS NULL OR #{self.table_name}.detail->>'last_inactive_time' <= ?) AND (#{self.table_name}.detail->>'permanently_disabled' IS NULL OR #{self.table_name}.detail->>'permanently_disabled' = '0')", (Time.now - 1.day)) }
  monetize :price_cents, with_currency: :aed

  # after_commit on: [:create] do
  #  Resque.enqueue(Indexer, :create, self.class.name, id) if self.is_published
  # end
  # before_update :call_create_logs
  #
  # after_commit on: [:update] do
  #  Resque.enqueue(Indexer, (self.is_published && self.is_available ? :create : :delete), self.class.name, id)
  # end
  #
  # after_commit on: [:destroy] do
  #  Resque.enqueue(Indexer, :delete, self.class.name, id)
  # end
  before_save :inactive_promotions

  def self.ransackable_scopes(_opts)
    [:product_barcode_includes]
  end

  scope :product_barcode_includes, lambda { |search|
    current_scope = self
    current_scope = current_scope.where(products: { barcode: search.split(',') })
    current_scope
  }

  def product
    Product.unscoped { super }
  end

  def inactive_promotions
    if (self.is_promotional_was && self.is_available_was && self.is_published_was) && !(self.is_promotional? && self.is_available? && self.is_published?)
      ShopPromotion.where(retailer_id: self.retailer_id, product_id: self.product_id, is_active: true).update_all(is_active: false)
    end
  end

  # def self.import
  #  Shop.includes(product: [:brand, {categories: :subcategories}]).find_in_batches do |shop|
  #    bulk_index(shop)
  #  end
  # end

  def self.perform(params, shop_data = nil)
    Searchjoy::Search.create params if params
    if shop_data
      shop = Shop.new(shop_data)
      Shop.unscoped.find(shop.id).create_logs(shop)
    end
  end

  # def self.prepare_records(shops)
  #  shops.map do |shop|
  #    { index: { _id: shop.id, data: shop.as_indexed_json } }
  #  end
  # end

  # def self.bulk_index(shops)
  #  Shop.__elasticsearch__.client.bulk({
  #    index: ::Shop.__elasticsearch__.index_name,
  #    type: ::Shop.__elasticsearch__.document_type,
  #    body: prepare_records(shops)
  #  })
  # end

  # def self.bulk_delete(shop_ids)
  #  # bulk update rank on ES
  #  Shop.__elasticsearch__.client.bulk({
  #    index: ::Shop.__elasticsearch__.index_name,
  #    type: ::Shop.__elasticsearch__.document_type,
  #    body: shop_ids.map do |shop_id|
  #      { delete: { _id: shop_id } }
  #    end
  #  })
  # end

  def as_indexed_json(*)
    if product.present?
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
          # if product.subcategories.include? child
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
      product_attrs
    end
  end.as_json

  attr_accessor :owner_for_log

  def call_create_logs
    if self.is_available_changed? || self.is_published_changed? || self.price_dollars_changed? || self.price_cents_changed?
      Resque.enqueue(Shop, nil, self)
    end
  end

  def create_logs(shop)
    ShopProductLog.create(retailer_id: self.retailer_id, product_id: self.product_id, category_id: self.product.try { |p| p.categories.first.id }, subcategory_id: self.product.try { |p| p.subcategories.first.id }, brand_id: self.product.brand_id, retailer_name: self.retailer.name, product_name: self.product.name,
                          brand_name: self.product.brand.name, category_name: self.product.try { |p| p.categories.first.name }, subcategory_name: self.product.try { |p| p.subcategories.first.name }, is_published: shop.is_published, is_available: shop.is_available, price: (self.price_dollars + self.price_cents / 100.0), owner: shop.owner_for_log) rescue nil
  end

  def product_attrs_hash
    {
      id: product_id,
      retailer_id: retailer_id,
      # locations: retailer.locations,
      name: product.name,
      name_ar: product.name_ar,
      category_name: categories.map(&:name),
      category_name_ar: categories.map(&:name_ar),
      subcategory_name: subcategories.map(&:name),
      subcategory_name_ar: subcategories.map(&:name_ar),
      brand_name: brand.try(:name),
      brand_name_ar: brand.try(:name_ar),
      barcode: product.barcode,
      brand: product.brand_hash,
      description: product.description,
      description_ar: product.description_ar,
      search_keywords: product.search_keywords,
      image_url: product.small_photo_url,
      full_image_url: product.photo_url,
      shelf_life: product.shelf_life,
      size_unit: product.size_unit,
      size_unit_ar: product.size_unit_ar,
      is_local: product.is_local,
      product_rank: product_rank.to_f,
      is_published: is_published,
      is_available: is_available,
      is_p: is_promotional,
      price: { price_cents: price_cents, price_currency: price_currency, price_dollars: price_dollars, price_full: (price_dollars.to_f + price_cents.to_f / 100) }
      # country: Country[product.country_alpha2] ? {alpha2: Country[product.country_alpha2].alpha2, name: Country[product.country_alpha2].name } : nil
    }
  end
end

# This class is Mapping Retailer Slots view to get the next available delivery slots
class ShopJoinRetailer < Shop
  self.table_name = 'shop_join_retailer'

  def readonly?
    true
  end

end
