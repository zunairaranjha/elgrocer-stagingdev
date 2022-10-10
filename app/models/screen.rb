class Screen < ActiveRecord::Base
  attr_accessor :select_all_retailers, :screen_retailer_ids, :screen_product_ids, :store_types_ids
  has_many :screen_products
  # has_many :screen_retailers
  has_many :products, through: :screen_products
  # has_many :retailers, through: :screen_retailers
  accepts_nested_attributes_for :screen_products, allow_destroy: true
  # accepts_nested_attributes_for :screen_retailers, allow_destroy: true
  validate :date_present

  has_attached_file :photo, :styles => { :large => "1000x1000", :medium => "300x300>", :icon => "50x50#" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/
  has_attached_file :photo_ar, :styles => { :large => "1000x1000", :medium => "300x300>", :icon => "50x50#" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :photo_ar, :content_type => /\Aimage\/.*\Z/
  has_attached_file :banner_photo, :styles => { :large => "1000x1000", :medium => "300x300>", :icon => "50x50#" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :banner_photo, :content_type => /\Aimage\/.*\Z/
  has_attached_file :banner_photo_ar, :styles => { :large => "1000x1000", :medium => "300x300>", :icon => "50x50#" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :banner_photo_ar, :content_type => /\Aimage\/.*\Z/

  def photo_url(size = 'large')
    photo ? photo.url(size) : nil
  end

  def photo_ar_url(size = 'large')
    photo_ar ? photo_ar.url(size) : nil
  end

  def banner_photo_url(size = 'large')
    banner_photo ? banner_photo.url(size) : nil
  end

  def banner_photo_ar_url(size = 'large')
    banner_photo_ar ? banner_photo_ar.url(size) : nil
  end

  ransacker :by_home_tier_1, formatter: proc{ |v|
    if v.to_i == 1
      data = Screen.where("? = ANY (locations)", Screen.screen_locations[:home_tier_1]).pluck(:id)
    else
      data = Screen.where.not("? = ANY (locations)", Screen.screen_locations[:home_tier_1]).pluck(:id)
    end
    data.blank? ? nil : data
  } do |parent|
    parent.table[:id]
  end

  ransacker :by_home_tier_2, formatter: proc{ |v|
    if v.to_i == 1
      data = Screen.where("? = ANY (locations)", Screen.screen_locations[:home_tier_2]).pluck(:id)
    else
      data = Screen.where.not("? = ANY (locations)", Screen.screen_locations[:home_tier_2]).pluck(:id)
    end
    data.blank? ? nil : data
  } do |parent|
    parent.table[:id]
  end

  ransacker :by_store_tier_1, formatter: proc{ |v|
    if v.to_i == 1
      data = Screen.where("? = ANY (locations)", Screen.screen_locations[:store_tier_1]).pluck(:id)
    else
      data = Screen.where.not("? = ANY (locations)", Screen.screen_locations[:store_tier_1]).pluck(:id)
    end
    data.blank? ? nil : data
  } do |parent|
    parent.table[:id]
  end

  ransacker :by_store_tier_2, formatter: proc{ |v|
    if v.to_i == 1
      data = Screen.where("? = ANY (locations)", Screen.screen_locations[:store_tier_2]).pluck(:id)
    else
      data = Screen.where.not("? = ANY (locations)", Screen.screen_locations[:store_tier_2]).pluck(:id)
    end
    data.blank? ? nil : data
  } do |parent|
    parent.table[:id]
  end

  enum screen_location: {
    "home_tier_1" => 1,
    "home_tier_2" => 2,
    "store_tier_1" => 3,
    "store_tier_2" => 4
}

  def date_present
    if start_date.blank?
      errors.add(:start_date, 'require')
    end
    if end_date.blank?
      errors.add(:end_date, 'required')
    end
  end
end