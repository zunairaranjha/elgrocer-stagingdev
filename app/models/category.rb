class Category < ActiveRecord::Base
  # acts_as_nested_set
  # include NameIndexing
  attr_accessor :select_all_retailers

  extend FriendlyId
  friendly_id :slug_candidates, use: %i[finders slugged]
  has_many :product_categories
  belongs_to :parent, optional: true, class_name: 'Category', foreign_key: 'parent_id'
  has_many :subcategories, -> { order(:name) }, class_name: 'Category', foreign_key: 'parent_id'
  has_many :products, through: :product_categories
  has_many :shops, through: :products
  has_many :retailer_categories
  has_many :retailers, through: :retailer_categories
  has_many :brands, through: :products
  has_many :shop_product_rule_categories
  has_many :shop_product_rules, through: :shop_product_rule_categories
  has_many :product_proposal_categories
  has_many :product_proposals, through: :product_proposal_categories
  has_attached_file :photo, styles: { medium: '300x300>', icon: '50x50#' }, default_url: 'https://api.elgrocer.com/images/:style/missing.png'
  has_attached_file :logo, styles: { medium: '300x300>', icon: '50x50#' }, default_url: 'https://api.elgrocer.com/images/:style/missing.png'
  has_attached_file :logo1, styles: { medium: '300x300>', icon: '50x50#' }, default_url: 'https://api.elgrocer.com/images/:style/missing.png'
  validates_attachment_content_type :photo, :logo, :logo1, content_type: /\Aimage\/.*\Z/
  alias colored_img logo
  alias colored_img_ar logo1
  validates_presence_of :name
  scope :without_photo, -> { where('categories.photo_file_size IS NULL') }
  scope :with_photo, -> { where('categories.photo_file_size IS NOT NULL') }
  scope :parent_categories, -> { where('categories.parent_id IS NULL') }

  ransacker :by_is_show_brand, formatter: proc { |v|
    data = if v.to_i == 1
             Category.where('? = ANY (current_tags)', Category.tags[:is_show_brand]).pluck(:id)
           else
             Category.where.not('? = ANY (current_tags)', Category.tags[:is_show_brand]).pluck(:id)
           end
    data.blank? ? nil : data
  } do |parent|
    parent.table[:id]
  end

  ransacker :by_is_food, formatter: proc { |v|
    data = if v.to_i == 1
             Category.where('? = ANY (current_tags)', Category.tags[:is_food]).pluck(:id)
           else
             Category.where.not('? = ANY (current_tags)', Category.tags[:is_food]).pluck(:id)
           end
    data.blank? ? nil : data
  } do |parent|
    parent.table[:id]
  end

  ransacker :by_pg_18, formatter: proc { |v|
    data = if v.to_i == 1
             Category.where('? = ANY (current_tags)', Category.tags[:pg_18]).pluck(:id)
           else
             Category.where.not('? = ANY (current_tags)', Category.tags[:pg_18]).pluck(:id)
           end
    data.blank? ? nil : data
  } do |parent|
    parent.table[:id]
  end

  enum tag: {
    'is_show_brand' => 1,
    'is_food' => 2,
    'pg_18' => 3
  }

  def slug_candidates
    [:name, %i[name id], randomize_slug]
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

  def to_param
    id.to_s
  end

  # after_move :rebuild_slug
  after_save :index_products

  # after_commit on: [:create] do
  #  Resque.enqueue(Indexer, :create, self.class.name, id)
  #  update_dependent_indexes
  # end
  #
  # after_commit on: [:update] do
  #  Resque.enqueue(Indexer, :update, self.class.name, id)
  #  update_dependent_indexes
  # end
  #
  # after_commit on: [:destroy] do
  #  Resque.enqueue(Indexer, :delete, self.class.name, id)
  #  update_dependent_indexes
  # end

  # def update_dependent_indexes
  #  # shops.each do |s|
  #  #   Resque.enqueue(Indexer, :update, s.class.name, s.id)
  #  # end
  #  # products.each do |p|
  #  #   Resque.enqueue(Indexer, :update, p.class.name, p.id)
  #  # end
  #  Resque.enqueue(Indexer, :bulk_index, self.class.name, self.id)
  # end

  def index_products
    product_ids = []
    product_ids = self.subcategories.map(&:product_ids) unless self.parent_id
    product_ids.push(self.product_ids)
    product_ids = product_ids.flatten
    return if product_ids.blank?

    product_ids.each_slice(1000) do |pro_ids|
      AlgoliaProductIndexingJob.perform_later(pro_ids)
    end
  end

  # def bulk_index
  #  shops.find_in_batches do |bshops|
  #    Shop.bulk_index(bshops)
  #  end
  #  products.find_in_batches do |bproducts|
  #    Product.bulk_index(bproducts)
  #  end
  # end

  def name
    value = self.send("name_#{I18n.locale.to_s}") if I18n.locale != :en and I18n.available_locales.include? I18n.locale
    value || read_attribute(:name)
  end

  def message
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.send("message_#{I18n.locale.to_s}")
    end
    value || read_attribute(:message)
  end

  def description
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.send("description_#{I18n.locale.to_s}")
    end
    value || read_attribute(:description)
  end

  def name_and_id
    "#{name} / #{id}"
  end

  # def rebuild_slug
  #   Category.rebuild!
  # end

  def photo_from_url(url)
    self.photo = open(url)
  end

  def image_url
    photo ? photo.url(:medium) : nil
  end

  def photo_url
    photo ? photo.url(:medium) : nil
  end

  def logo_url
    logo ? logo.url(:medium) : photo_url
  end

  alias colored_img_url logo_url

  def logo1_url
    logo1 ? logo1.url(:medium) : logo_url
  end

  alias colored_img_url_ar logo1_url

  def shop_brands
    result = []
    shops.each do |shop|
      if shop.product.brand
        result.push(shop.product.brand) if shop.product.brand.name
      end
    end
    _result = result.uniq!

    check_results(_result, result)

  end

  def brands
    result = []
    products.each do |product|
      if product.brand
        result.push(product.brand) if product.brand.name
      end
    end
    _result = result.uniq!

    check_results(_result, result)
  end

  def check_results(_result, result)
    if !_result.nil?
      _result = _result.sort_by { |hsh| hsh[:name] }
      _result
    else
      result = result.sort_by { |hsh| hsh[:name] }
      result
    end
  end

  def self.get_categories(retailer_id)
    Category.distinct.joins('JOIN categories AS subcategories ON categories.id = subcategories.parent_id')
            .joins('JOIN product_categories ON product_categories.category_id = subcategories.id')
            .joins('JOIN products ON products.id = product_categories.product_id AND products.photo_file_size IS NOT NULL')
            .joins("JOIN shops ON shops.product_id = products.id AND shops.is_available = 't' AND shops.is_published = 't' AND retailer_id = #{retailer_id}")
            .joins("JOIN retailer_categories ON retailer_categories.category_id = categories.id AND retailer_categories.retailer_id = #{retailer_id}")
            .where(parent_id: nil)
  end

  def self.get_subcategories(retailer_id, parent_id)
    Category.distinct.joins('JOIN product_categories ON product_categories.category_id = categories.id')
            .joins('JOIN products ON products.id = product_categories.product_id AND products.photo_file_size IS NOT NULL')
            .joins("JOIN shops ON shops.product_id = products.id AND shops.is_available = 't' AND shops.is_published = 't' AND retailer_id = #{retailer_id}")
            .joins("JOIN retailer_categories ON retailer_categories.category_id = categories.id AND retailer_categories.retailer_id = #{retailer_id}")
            .where(parent_id: parent_id)
  end

  def self.categories_list(retailer_id, delivery_time, category_id = nil)
    sql1 = Category.joins('JOIN categories AS subcategories ON categories.id = subcategories.parent_id')
                   .joins("JOIN retailer_categories ON retailer_categories.category_id = categories.id AND retailer_categories.retailer_id = #{retailer_id}")
                   .joins('JOIN product_categories ON product_categories.category_id = subcategories.id')
                   .joins('JOIN products ON products.id = product_categories.product_id AND products.photo_file_size IS NOT NULL')
                   .joins("JOIN shops ON shops.product_id = products.id AND shops.is_available = 't' AND shops.is_published = 't' AND shops.retailer_id = #{retailer_id} AND shops.promotion_only = 'f'")
    sql1 = sql1.where("categories.id = #{category_id.to_i} or categories.slug = '#{category_id}'") if category_id
    sql1 = sql1.where(parent_id: nil).to_sql
    sql2 = Category.joins('JOIN categories AS subcategories ON categories.id = subcategories.parent_id')
                   .joins("JOIN retailer_categories ON retailer_categories.category_id = categories.id AND retailer_categories.retailer_id = #{retailer_id}")
                   .joins('JOIN product_categories ON product_categories.category_id = subcategories.id')
                   .joins('JOIN products ON products.id = product_categories.product_id AND products.photo_file_size IS NOT NULL')
                   .joins("JOIN shops ON shops.product_id = products.id AND shops.is_available = 't' AND shops.is_published = 't' AND shops.retailer_id = #{retailer_id} AND shops.promotion_only = 't' AND shops.is_promotional = 't'")
                   .joins("JOIN shop_promotions ON shop_promotions.product_id = products.id AND shop_promotions.retailer_id = #{retailer_id} AND #{delivery_time} BETWEEN start_time AND end_time")
    sql2 = sql2.where("categories.id = #{category_id.to_i} or categories.slug = '#{category_id}'") if category_id
    sql2 = sql2.where(parent_id: nil).to_sql
    Category.find_by_sql("(#{sql1}) UNION (#{sql2}) order by priority")
  end

  def self.subcategories_list(retailer_id, parent_id, delivery_time)
    sql1 = Category.joins("JOIN retailer_categories ON retailer_categories.category_id = categories.id AND retailer_categories.retailer_id = #{retailer_id}")
                   .joins('JOIN product_categories ON product_categories.category_id = categories.id')
                   .joins('JOIN products ON products.id = product_categories.product_id AND products.photo_file_size IS NOT NULL')
                   .joins("JOIN shops ON shops.product_id = products.id AND shops.is_available = 't' AND shops.is_published = 't' AND shops.retailer_id = #{retailer_id} AND shops.promotion_only = 'f'")
                   .where(parent_id: parent_id).to_sql
    sql2 = Category.joins("JOIN retailer_categories ON retailer_categories.category_id = categories.id AND retailer_categories.retailer_id = #{retailer_id}")
                   .joins('JOIN product_categories ON product_categories.category_id = categories.id')
                   .joins('JOIN products ON products.id = product_categories.product_id AND products.photo_file_size IS NOT NULL')
                   .joins("JOIN shops ON shops.product_id = products.id AND shops.is_available = 't' AND shops.is_published = 't' AND shops.retailer_id = #{retailer_id} AND shops.promotion_only = 't' AND shops.is_promotional = 't'")
                   .joins("JOIN shop_promotions ON shop_promotions.product_id = products.id AND shop_promotions.retailer_id = #{retailer_id} AND #{delivery_time} BETWEEN start_time AND end_time")
                   .where(parent_id: parent_id).to_sql
    Category.find_by_sql("(#{sql1}) UNION (#{sql2}) order by priority")
  end

  # def self.import
  #  Category.includes(subcategories: :brands).find_in_batches do |category|
  #    bulk_index(category)
  #  end
  # end
  #
  # def self.prepare_records(categories)
  #  categories.map do |category|
  #    { index: { _id: category.id, data: category.as_indexed_json } }
  #  end
  # end

  # def self.bulk_index(categories)
  #  Category.__elasticsearch__.client.bulk({
  #    index: ::Category.__elasticsearch__.index_name,
  #    type: ::Category.__elasticsearch__.document_type,
  #    body: prepare_records(categories)
  #  })
  # end

  def as_indexed_json(options = {})
    category_attrs = {
      id: id,
      name: name,
      image_url: photo_url
    }

    category_attrs[:children] = subcategories.map do |child|
      result_child = nil

      result_child = {
        id: child.id,
        name: child.name,
        image_url: child.photo_url
      }
      result_child[:brands] = child.brands.map do |brand|
        if brand.nil?
          {
            id: -1,
            name: 'Other',
            image_url: nil
          }
        else
          {
            id: brand.id,
            name: brand.name,
            image_url: brand.photo_url
          }
        end
      end
      result_child
    end

    category_attrs.as_json
  end

  private

  def randomize_slug
    begin
      new_slug = "#{self.name}-#{SecureRandom.random_number(999999).to_s}"
    end while Category.where(slug: new_slug).exists?
    new_slug
  end

end
