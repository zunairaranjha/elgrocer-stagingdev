class ProductProposal < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: %i[finders slugged]
  has_many :product_proposal_categories
  has_many :subcategories, through: :product_proposal_categories, source: :category
  has_many :categories, through: :subcategories, source: :parent
  belongs_to :order, optional: true
  belongs_to :retailer, optional: true
  belongs_to :product, optional: true
  belongs_to :brand, optional: true
  has_one :order_substitution
  has_one :order_position
  has_one :image, as: :record
  accepts_nested_attributes_for :image, allow_destroy: true

  def slug_candidates
    [:name, %i[name id], randomize_slug]
  end

  def description
    details['description']
  end

  def shop_id
    details['shop_id']
  end

  enum status_ids: {
    pending: 0,
    verified: 1,
    work_in_progress: 2,
    complete: 3
  }

  enum type_ids: {
    price_variance: 0,
    oos_in_store: 1,
    not_in_store_file: 2,
    not_in_master_db: 3,
    data_not_correct: 4
  }

  def photo_url(size = 'medium')
    image&.photo ? image.photo.url(size) : nil
  end

  private

  def randomize_slug
    begin
      new_slug = "#{self.name}-#{SecureRandom.random_number(999999).to_s}"
    end while Brand.where(slug: new_slug).exists?
    new_slug
  end
end
