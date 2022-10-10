class DeliveryZone < ActiveRecord::Base
  include ZonesWithPoint

  has_many :retailer_delivery_zones
  has_many :retailers, through: :retailer_delivery_zones
  has_attached_file :kml, s3_headers: {
    "Content-Disposition" => "attachment; filename=polygon.kml",
    "Content-Type" => "application/vnd.google-earth.kml+xml;"}
  validates_attachment_file_name :kml, matches: [/kml\Z/]

  def self.ransackable_scopes(_opts)
    [:retailer_id_includes]
  end

  scope :retailer_id_includes, ->(search) {
    current_scope = self
    current_scope = current_scope.joins("LEFT OUTER JOIN retailer_delivery_zones ON retailer_delivery_zones.delivery_zone_id = delivery_zones.id where retailer_delivery_zones.retailer_id IN (#{search})")
    current_scope
  }

  def to_lonlat_array
    return unless coordinates.present?
    coordinates_array.map{|ca| { longitude: ca[0].to_f, latitude: ca[1].to_f } }
  end

  def coords_to_json
    latlon_coords.to_json
  end

  def latlon_coords
    coordinates_array.map{|ca| { lng: ca[0].to_f, lat: ca[1].to_f } }
  end

  private

  def coordinates_array
    coordinates.to_s.sub(/POLYGON \(\(/, "").sub(/\)\)/, "").split(', ').map{|p| p.split(' ')}
  end
end
