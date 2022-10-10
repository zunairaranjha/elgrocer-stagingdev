class BannerLink < ActiveRecord::Base
  belongs_to :banner, optional: true, touch: true
  has_attached_file :photo, :styles => { :large => "1000x1000>", :medium => "300x300>", :icon => "50x50#" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/
  belongs_to :brand, optional: true
  belongs_to :category, optional: true
  belongs_to :subcategory, optional: true, :class_name => "Category"

  def photo_url
    photo ? photo.url(:large) : nil
  end
end
