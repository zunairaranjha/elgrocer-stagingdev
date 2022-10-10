class DeliveryZone::ScheduleShopperService < Struct.new(:longitude, :latitude)
  def find_delivery_zones
    DeliveryZone.with_point(lonlat)
  end

  def is_covered?
    Retailer.joins(:delivery_zones).with_point(lonlat).exists?
  end

  def is_covered_and_active?
    Retailer.joins(:delivery_zones).with_point(lonlat).where(is_active: true).exists?
  end

  def retailers_on_line?
    retailers_active_all.exists?
  end

  def retailers_active_all
    Retailer.joins(:delivery_zones)
      .where(is_active: true)
      .with_point(lonlat).distinct
  end

  private

  def lonlat
    "POINT (#{longitude} #{latitude})"
  end
end
