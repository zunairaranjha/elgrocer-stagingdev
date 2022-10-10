class AddAcceptPromocodeToRetailerHasAvailablePaymentTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :retailer_has_available_payment_types, :accept_promocode, :boolean, :default => true
  end
end
