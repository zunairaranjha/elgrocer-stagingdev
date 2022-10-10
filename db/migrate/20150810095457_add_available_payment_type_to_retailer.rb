class AddAvailablePaymentTypeToRetailer < ActiveRecord::Migration
  def up
    add_column :retailers, :available_payment_type, :integer
  end

  def down
    remove_column :retailers, :available_payment_type
  end
end
