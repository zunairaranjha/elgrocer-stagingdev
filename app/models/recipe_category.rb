class RecipeCategory < ActiveRecord::Base
  attr_accessor :name_ar, :name_en
  extend FriendlyId
  friendly_id :slug_candidates, use: [:finders, :slugged, :history]
  has_many :recipes_categories
  has_many :recipes, through: :recipes_categories
  belongs_to :parent, optional: true, :class_name => "RecipeCategory", :foreign_key => "parent_id"
  has_many :recipe_subcategories, -> { order(:name) }, :class_name => "RecipeCategory", foreign_key: "parent_id"

  has_attached_file :photo, :styles => { :medium => "300x300>", :icon => "50x50#" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/

  after_save :index_recipes

  def photo_url
    photo ? photo.url(:medium) : nil
  end

  def small_photo_url
    photo ? photo.url(:medium) : nil
  end

  def slug_candidates
    [:name, [:name, :id], randomize_slug]
  end

  def should_generate_new_friendly_id?
    self.name = name_en
    name_changed? || super
  end

  def to_param
    id.to_s
  end

  def name_and_id
    "#{name} / #{id}"
  end

  def index_recipes
    recipe_ids = self.recipe_ids
    Recipe.where(id: recipe_ids).includes(:chef, :recipe_categories, ingredients: :product).reindex! if recipe_ids.any?
  end

  def name
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      name = self.send("name_#{I18n.locale.to_s}")
    end
    name.present? && name || self.send("name_en")
  end

  def name_ar
    self.translations["name_ar"]
  end

  def name_en
    self.translations["name_en"]
  end

  private

  def randomize_slug
    begin
      new_slug = "#{self.name}-#{SecureRandom.random_number(999999).to_s}"
    end while RecipeCategory.where(slug: new_slug).exists?
    new_slug
  end

end
