class ChangeDeliveryMethodToRetailerService < ActiveRecord::Migration[4.2]
  def change
    rename_column :orders, :delivery_method, :retailer_service_id
  end
end
