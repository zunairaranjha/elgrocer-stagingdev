class AddKmlAttachmentToDeliveryZones < ActiveRecord::Migration
  def change
    add_attachment :delivery_zones, :kml
  end
end
