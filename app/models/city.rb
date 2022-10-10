class City < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: [:finders, :slugged, :history]

  validates_presence_of :name, :vat

  has_many :locations, foreign_key: :city_id, dependent: :restrict_with_exception
  has_and_belongs_to_many :referral_rules

  def slug_candidates
    [:name, [:name, :id], randomize_slug]
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def to_param
    id.to_s
  end

  private

  def randomize_slug
    begin
      new_slug = "#{self.name}-#{SecureRandom.random_number(999999).to_s}"
    end while City.where(slug: new_slug).exists?
    new_slug
  end

end
