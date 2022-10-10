class Location < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: [:finders, :slugged, :history]

  # default_scope { where(active: true) }

  validates_presence_of :city, :name
  validates :name, uniqueness: true

  has_many :shopper_addresses
  has_many :retailer_has_locations
  has_many :retailers, through: :retailer_has_locations
  belongs_to :city, optional: true, foreign_key: :city_id
  belongs_to :primary_location, optional: true, class_name: 'Location', foreign_key: 'primary_location_id'

  attr_accessor :is_covered

  def slug_candidates
    [:name, [:name, :id], randomize_slug]
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def to_param
    id.to_s
  end

  def is_covered
    RetailerHasLocation.joins(:retailer)
                       .where(location_id: self.id, retailers: { is_active: true }).count > 0
  end

  def primary_id
    return primary_location.id unless primary_location.nil?
    id
  end

  def set_primary(correct_location)
    Location.transaction do
      Retailer.where(location_id: id).update_all(location_id: correct_location.id)
      RetailerHasLocation.where(location_id: id).update_all(location_id: correct_location.id)
      ShopperAddress.where(location_id: id).update_all(location_id: correct_location.id)
      Product.where(location_id: id).update_all(location_id: correct_location.id)
      Location.unscoped.where(primary_location_id: id).update_all(primary_location_id: correct_location.id)
    end

    self.active = false
    self.primary_location = correct_location
    save!
  end

  def min_basket_value(retailer_id)
    retailer_has_locations.find_by_retailer_id(retailer_id).min_basket_value
  end

  private

  def randomize_slug
    begin
      new_slug = "#{self.name}-#{SecureRandom.random_number(999999).to_s}"
    end while Location.where(slug: new_slug).exists?
    new_slug
  end
end
