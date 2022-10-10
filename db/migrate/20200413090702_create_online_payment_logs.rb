class CreateOnlinePaymentLogs < ActiveRecord::Migration
  def change
    create_table :online_payment_logs do |t|
      t.integer :order_id
      t.string :fort_id
      t.string :merchant_reference
      t.float :amount
      t.string :method
      t.string :status
      t.string :authorization_code

      t.timestamps null: false
    end
  end
end
