class Campaign < ActiveRecord::Base
  attr_accessor :select_all_retailers, :campaign_category_ids, :campaign_subcategory_ids, :campaign_brand_ids, :campaign_retailer_ids, :campaign_store_type_ids, :campaign_retailer_group_ids, :campaign_product_ids, :campaign_locations, :campaign_keywords, :campaign_exclude_retailer_ids
  validate :date_present
  has_many :campaign_categories
  has_many :c_categories, through: :campaign_categories, source: :category
  has_many :campaign_subcategories
  has_many :c_subcategories, through: :campaign_subcategories, source: :category
  has_many :campaign_brands
  has_many :c_brands, through: :campaign_brands, source: :brand

  has_attached_file :photo, :styles => { :large => "1000x1000", :icon => "100x100" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/
  has_attached_file :photo_ar, :styles => { :large => "1000x1000", :icon => "100x100" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :photo_ar, :content_type => /\Aimage\/.*\Z/
  has_attached_file :banner, :styles => { :large => "1000x1000", :icon => "100x100" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :banner, :content_type => /\Aimage\/.*\Z/
  has_attached_file :banner_ar, :styles => { :large => "1000x1000", :icon => "100x100" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :banner_ar, :content_type => /\Aimage\/.*\Z/
  has_attached_file :web_photo, :styles => { :xlarge => "1500x1500", :large => "1000x1000", :icon => "100x100" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :web_photo, :content_type => /\Aimage\/.*\Z/
  has_attached_file :web_photo_ar, :styles => { :xlarge => "1500x1500", :large => "1000x1000", :icon => "100x100" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :web_photo_ar, :content_type => /\Aimage\/.*\Z/
  has_attached_file :web_banner, :styles => { :xlarge => "1500x1500", :large => "1000x1000", :icon => "100x100" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :web_banner, :content_type => /\Aimage\/.*\Z/
  has_attached_file :web_banner_ar, :styles => { :xlarge => "1500x1500", :large => "1000x1000", :icon => "100x100" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :web_banner_ar, :content_type => /\Aimage\/.*\Z/

  def photo_url(size = 'large')
    if I18n.locale == :ar
      return photo_ar.url(size) if photo_ar
    end
    photo ? photo.url(size) : nil
  end

  def photo_ar_url(size = 'large')
    photo_ar ? photo_ar.url(size) : nil
  end

  def banner_url(size = 'large')
    if I18n.locale == :ar
      return banner_ar.url(size) if banner_ar
    end
    banner ? banner.url(size) : nil
  end

  def banner_ar_url(size = 'large')
    banner_ar ? banner_ar.url(size) : nil
  end

  def web_photo_url(size = 'xlarge')
    if I18n.locale == :ar
      return web_photo_ar.url(size) if web_photo_ar
    end
    web_photo ? web_photo.url(size) : nil
  end

  def web_photo_ar_url(size = 'xlarge')
    web_photo_ar ? web_photo_ar.url(size) : nil
  end

  def web_banner_url(size = 'xlarge')
    if I18n.locale == :ar
      return web_banner_ar.url(size) if web_banner_ar
    end
    web_banner ? web_banner.url(size) : nil
  end

  def web_banner_ar_url(size = 'xlarge')
    web_banner_ar ? web_banner_ar.url(size) : nil
  end

  def name
    if I18n.locale == :ar
      value = self.send("name_#{I18n.locale.to_s}")
    end
    value || read_attribute(:name)
  end

  ransacker :by_location, formatter: proc { |v|
    data = Campaign.where("? = ANY (locations)", v).ids
    data.blank? ? nil : data
  } do |parent|
    parent.table[:id]
  end

  def date_present
    if start_time.blank?
      errors.add(:start_time, 'require')
    end
    if end_time.blank?
      errors.add(:end_time, 'required')
    end
  end
end

class CampaignCategory < ActiveRecord::Base
  self.table_name = "campaign_categories"
  belongs_to :category, optional: true
  belongs_to :campaign, optional: true

  def readonly?
    true
  end

end

class CampaignSubcategory < ActiveRecord::Base
  self.table_name = "campaign_subcategories"
  belongs_to :category, optional: true
  belongs_to :campaign, optional: true

  def readonly?
    true
  end

end

class CampaignBrand < ActiveRecord::Base
  self.table_name = "campaign_brands"
  belongs_to :brand, optional: true
  belongs_to :campaign, optional: true

  def readonly?
    true
  end

end
