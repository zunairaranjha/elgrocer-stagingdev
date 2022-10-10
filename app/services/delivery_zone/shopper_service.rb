class DeliveryZone::ShopperService < Struct.new(:longitude, :latitude)
  def find_delivery_zones
    DeliveryZone.with_point(lonlat)
  end

  def is_covered?
    Retailer.joins(:delivery_zones).with_point(lonlat).exists?
  end

  def is_covered_and_active?
    Retailer.joins(:delivery_zones).with_point(lonlat).where(is_active: true).where('delivery_type_id != 1').exists?
  end

  def retailers_on_line?
    retailers_active_all.exists?
  end

  def retailers_active_all
    Retailer.joins(:delivery_zones)
      .where(is_active: true, is_opened: true)
      .where('delivery_type_id != 1')
      .opened_hours
      .with_point(lonlat).distinct
  end

  def is_covered_for_retailer?(retailer_id)
    DeliveryZone.with_point("POINT (#{longitude} #{latitude})").joins(:retailer_delivery_zones).where(retailer_delivery_zones: {retailer_id: retailer_id}).select("retailer_delivery_zones.*").first
    # Retailer.joins(:delivery_zones).with_point(lonlat).where(id: retailer_id,is_active: true).exists?
  end

  private

  def lonlat
    "POINT (#{longitude} #{latitude})"
  end
end