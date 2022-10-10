class Brand < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: [:finders, :slugged]
  has_many :products
  has_many :shops, through: :products
  has_many :shop_promotions, through: :products
  has_many :retailers, through: :shops
  has_many :product_categories, through: :products
  has_many :subcategories, through: :product_categories, source: :category
  has_many :categories, :through => :subcategories, source: :parent
  has_and_belongs_to_many :promotion_codes

  validates_presence_of :name
  validates :name, uniqueness: { :case_sensitive => false }
  validates :name_ar, uniqueness: { :case_sensitive => false }, :allow_blank => true

  before_save :validate_priority
  after_save :index_products

  #after_commit on: [:create] do
  #  update_dependent_indexes
  #end
  #
  #after_commit on: [:update] do
  #  update_dependent_indexes
  #end
  #
  #after_commit on: [:destroy] do
  #  update_dependent_indexes
  #end

  #def update_dependent_indexes
  #  # shops.each do |s|
  #  #   Resque.enqueue(Indexer, :update, s.class.name, s.id)
  #  # end
  #  # products.each do |p|
  #  #   Resque.enqueue(Indexer, :update, p.class.name, p.id)
  #  # end
  #  Resque.enqueue(Indexer, :bulk_index, self.class.name, self.id)
  #end

  def index_products
    product_ids = self.product_ids
    unless product_ids.blank?
      product_ids.each_slice(1000) do |pro_ids|
        AlgoliaProductIndexingJob.perform_later(pro_ids)
      end
    end
  end

  #def bulk_index
  #  shops.find_in_batches do |bshops|
  #    Shop.bulk_index(bshops)
  #  end
  #  products.find_in_batches do |bproducts|
  #    Product.bulk_index(bproducts)
  #  end
  #end

  has_attached_file :photo, :styles => { :large => "700x700>", :medium => "300x300>", :icon => "50x50#" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  has_attached_file :brand_logo_1, :styles => { :medium => "300x300>", :icon => "50x50#" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  has_attached_file :brand_logo_2, :styles => { :medium => "300x300>", :icon => "50x50#" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"

  validates_attachment_content_type :photo, :brand_logo_1, :brand_logo_2, :content_type => /\Aimage\/.*\Z/

  def slug_candidates
    [:name, [:name, :id], randomize_slug]
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def to_param
    id.to_s
  end

  def name
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.send("name_#{I18n.locale.to_s}")
    end
    value || read_attribute(:name)
  end

  def name_and_id
    "#{name} / #{id}"
  end

  def photo_from_url(url)
    self.photo = open(url)
  end

  def photo_url
    photo ? photo.url(:large) : nil
  end

  def logo1_url
    brand_logo_1 ? brand_logo_1.url(:medium) : photo.url(:medium)
  end

  def logo2_url
    brand_logo_2 ? brand_logo_2.url(:medium) : brand_logo_1.url(:medium)
  end

  def validate_priority
    self.priority = 0 if self.priority.blank?
  end

  private

  def randomize_slug
    begin
      new_slug = "#{self.name}-#{SecureRandom.random_number(999999).to_s}"
    end while Brand.where(slug: new_slug).exists?
    new_slug
  end

end
