module ZonesWithPoint
  extend ActiveSupport::Concern

  included do
    scope :with_point, -> (point){
        where("ST_Contains(delivery_zones.coordinates, ST_GeomFromText(?)) = 't'", point)
      }
  end
end
