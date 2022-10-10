class StoreType < ActiveRecord::Base
  has_many :retailer_store_types
  has_many :retailers, through: :retailer_store_types
  has_one :image, as: :record, dependent: :destroy

  accepts_nested_attributes_for :image, allow_destroy: true

  has_attached_file :photo, styles: { medium: '300x300>', icon: '50x50#' }, default_url: 'https://api.elgrocer.com/images/:style/missing.png'
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\Z/

  def image_url
    photo ? photo.url(:medium) : nil
  end

  def slug_candidates
    [:name, %i[name id]]
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def name
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.send("name_#{I18n.locale.to_s}")
    end
    value || read_attribute(:name)
  end

  def colored_image_url
    image&.photo_url || image_url
  end

end
