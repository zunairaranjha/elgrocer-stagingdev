class ShopperAddress < ActiveRecord::Base
  belongs_to :shopper, optional: true
  belongs_to :location, optional: true
  belongs_to :address_tag, optional: true

  before_validation :reset_default_address, on: [:create, :update]
  validates_uniqueness_of :default_address, scope: :shopper_id, if: :default_address
  validates :lonlat, presence: true
  after_save :update_address_attributes

  #after_create :send_welcome_email_to_user

  def has_coordinates?
    lonlat.is_a? RGeo::Geos::CAPIPointImpl
  end

  def location_name
    location ? location.name : 'Not specified'
  end

  def destroy
    raise 'Cannot delete default address!' if default_address
    super
  end

  def reset_default_address
    self.class.where.not(id: id).where(shopper_id: shopper_id, default_address: true).update_all(default_address: false) if default_address
  end

  def longitude
    lonlat.try(:x)
  end

  def latitude
    lonlat.try(:y)
  end

  def is_covered
    DeliveryZone::ShopperService.new(longitude,latitude).is_covered?
  end

  def name
    # "#{shopper && shopper.email} : #{self.street_address}"
    self.location_name
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

  def send_welcome_email_to_user
    ShopperMailer.welcome_shopper(shopper_id, longitude, latitude).deliver_later
  end

end
