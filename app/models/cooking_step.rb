class CookingStep < ActiveRecord::Base
  attr_accessor :step_detail_en, :step_detail_ar
  belongs_to :recipe, optional: true
  
  has_attached_file :photo, :styles => { :medium => "300x300>", :icon => "50x50#" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/

  def photo_url
    photo ? photo.url(:medium) : nil
  end

  def small_photo_url
    photo ? photo.url(:medium) : nil
  end

  def step_detail_en
    translations["step_detail_en"]
  end

  def step_detail_ar
    translations["step_detail_ar"]
  end

  def step_detail
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      step_detail = self.send("step_detail_#{I18n.locale.to_s}")
    end
    step_detail.present? && step_detail || self.send("step_detail_en")
  end

end
