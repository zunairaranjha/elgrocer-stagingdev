class AddRetailerServiceIdToRetailerHasAvailablePaymentTypes < ActiveRecord::Migration[4.2]
  def change
    add_column :retailer_has_available_payment_types, :retailer_service_id, :integer
  end
end
