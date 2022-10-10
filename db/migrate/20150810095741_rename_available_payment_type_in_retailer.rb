class RenameAvailablePaymentTypeInRetailer < ActiveRecord::Migration
  def up
    execute "ALTER TABLE retailers RENAME COLUMN available_payment_type TO available_payment_type_id"
  end

  def down
    execute "ALTER TABLE retailers RENAME COLUMN available_payment_type_id TO available_payment_type"
  end
end
