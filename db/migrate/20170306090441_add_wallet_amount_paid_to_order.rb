class AddWalletAmountPaidToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :wallet_amount_paid, :decimal
  end
end
