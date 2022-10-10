class AddAmountRefundedAndDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :refunded_amount, :integer
    add_column :online_payment_logs, :details, :jsonb, default: {}
  end
end
