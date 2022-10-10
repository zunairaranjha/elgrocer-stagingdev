# frozen_string_literal: true

class Recipe < ActiveRecord::Base
  attr_accessor :name_en, :name_ar, :description_en, :description_ar, :recipe_retailer_ids, :recipe_retailer_group_ids,
                :recipe_store_type_ids, :recipe_exclude_retailer_ids, :select_all_retailers

  # include NameIndexing
  include AlgoliaRecipeIndexing
  extend FriendlyId
  friendly_id :slug_candidates, use: %i[finders slugged]
  belongs_to :chef, optional: true
  # belongs_to :recipe_category, optional: true #,:through => :recipe_subcategory, :source => :parent
  # has_one :recipe_subcategory
  has_many :ingredients, dependent: :destroy
  has_many :cooking_steps, dependent: :destroy
  has_many :shopper_recipes
  has_many :shoppers, through: :shopper_recipes
  has_many :recipes_categories
  has_many :recipe_categories, through: :recipes_categories
  has_many :images, as: :record
  scope :published, -> { where(is_published: true) }
  accepts_nested_attributes_for :ingredients, allow_destroy: true
  accepts_nested_attributes_for :cooking_steps, allow_destroy: true
  accepts_nested_attributes_for :images, allow_destroy: true

  has_attached_file :photo, styles: { large: '700x700', medium: '300x300>', icon: '50x50#' }, default_url: 'https://api.elgrocer.com/images/:style/missing.png'
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\Z/
  validate :validate_image_size

  def photo_url(size = 'large')
    photo ? photo.url(size) : nil
  end

  def small_photo_url
    photo ? photo.url(:medium) : nil
  end

  def slug_candidates
    [:name, %i[name id], randomize_slug]
  end

  def should_generate_new_friendly_id?
    self.name = name_en
    name_changed? || super
  end

  def to_param
    id.to_s
  end

  def name
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      name = self.send("name_#{I18n.locale.to_s}")
    end
    name.present? && name || self.send('name_en')
  end

  def name_en
    translations['name_en']
  end

  def name_ar
    translations['name_ar']
  end

  def description
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.send("description_#{I18n.locale.to_s}")
    end
    value.present? && value || self.send('description_en')
  end

  def description_en
    translations['description_en']
  end

  def description_ar
    translations['description_ar']
  end

  def validate_image_size
    errors.add(:photo, 'Photo file size must be under 2mbs') if photo.present? and photo.size > 2.megabytes
  end


  # def self.import
  #  Recipe.includes(:chef, :recipe_category, ingredients: :product).find_in_batches do |recipe|
  #    bulk_index(recipe)
  #  end
  # end

  # def self.prepare_records(recipes)
  #  recipes.map do |recipe|
  #    { index: { _id: recipe.id, data: recipe.as_indexed_json } }
  #  end
  # end

  # def self.bulk_index(recipes)
  #  Recipe.__elasticsearch__.client.bulk({
  #    index: ::Recipe.__elasticsearch__.index_name,
  #    type: ::Recipe.__elasticsearch__.document_type,
  #    body: prepare_records(recipes)
  #  })
  # end

  def as_indexed_json(*)
    recipe_attrs = {
      id: id,
      name: self.name,
      name_ar: self.name_ar,
      image_url: self.photo_url,
      # category_id: self.recipe_category_id,
      # category_name: recipe_category.name,
      slug: self.slug,
      is_published: self.is_published,
      retailer_ids: self.retailer_ids,
      retailer_group_ids: self.retailer_group_ids,
      store_type_ids: self.store_type_ids
      # subcategory_id: self.recipe_category_id,
      # subcategory_name: recipe_category.name,
      # category_id: recipe_category.parent_id,
      # category_name: recipe_category.parent.name,
    }
    recipe_attrs[:recipe_categories] = recipe_categories.map do |recipe_category|
      result = {
        id: recipe_category.id,
        name: recipe_category.name,
        slug: recipe_category.slug,
        image_url: recipe_category.photo_url,
        name_ar: recipe_category.name_ar
      }
    end
    recipe_attrs[:chef] = {
      id: self.chef_id,
      name: chef.name,
      slug: chef.slug,
      name_ar: chef.name_ar,
      image_url: chef.photo_url
    }
    recipe_attrs[:ingredients] = ingredients.map do |ingredient|
      result = {
        id: ingredient.id,
        name: ingredient.product.name
      }
    end
    recipe_attrs.as_json
  end

  private

  def randomize_slug
    begin
      new_slug = "#{self.name}-#{SecureRandom.random_number(999999).to_s}"
    end while Recipe.where(slug: new_slug).exists?
    new_slug
  end

end
