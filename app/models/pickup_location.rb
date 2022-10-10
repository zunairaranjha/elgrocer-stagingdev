class PickupLocation < ActiveRecord::Base
  belongs_to :retailer, optional: true
  has_attached_file :photo, :styles => { :large => "1000x1000", :medium => "500X500>", :icon => "50x50#" }, :default_url => "https://api.elgrocer.com/images/:style/missing.png"
  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/

  def pickup_longitude
    lonlat.try(:x)
  end

  def pickup_latitude
    lonlat.try(:y)
  end

  def photo_url(size = 'medium')
    photo ? photo.url(size) : nil
  end

  def details
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.send("details_#{I18n.locale.to_s}") 
    end
    value || read_attribute(:details)
  end
end

class PickupLoc < PickupLocation

  self.table_name = "pickup_loc"

  def readonly?
    true
  end

  # def longitude
  #   # self.longitude
  # end
  #
  # def latitude
  #   # self.latitude
  # end
end
