class ALocationWithoutShop < ActiveRecord::Base
  belongs_to :shopper, optional: true

  # reverse_geocoded_by :latitude, :longitude, :address => :street_address
  # after_validation :reverse_geocode  # auto-fetch address

  validates :latitude, presence: true
  validates :longitude, presence: true
  after_save :update_address_attributes

  def has_coordinates?
    longitude.presenct? && latitude.present?
  end

  def is_covered
    DeliveryZone::ShopperService.new(longitude,latitude).is_covered?
  end

  def update_address_attributes
    geo_localization = "#{latitude},#{longitude}"
    find_geolocalization(geo_localization)
  end

  def find_geolocalization(geo_localization)
    result = Geocoder.search(geo_localization).first
    if result.present?
      result = result.data
      new_values = Hash.new()
      result["address_components"].each do |r|
        type = r['types'].reject{|r| r == 'political'}.first
        new_values[type] = r['long_name']
      end
      attributes = ['street_address', 'street_number', 'route', 'country', 'administrative_area_level_1',
                    'locality', 'sublocality', 'neighborhood', 'premise']
      new_values['street_address'] = result['formatted_address']
      new_values.reject!{ |k| attributes.exclude?(k)}
      self.update_columns(new_values)
    else
      Airbrake.notify("Geocoder: #{self.class.name}, id:#{self.id}")
    end
  end
end
