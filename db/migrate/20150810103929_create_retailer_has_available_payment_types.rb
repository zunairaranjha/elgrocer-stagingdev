class CreateRetailerHasAvailablePaymentTypes < ActiveRecord::Migration
  def change
    create_table :retailer_has_available_payment_types do |t|
        t.integer :retailer_id
        t.integer :available_payment_type_id
        t.timestamps
    end
  end
end
