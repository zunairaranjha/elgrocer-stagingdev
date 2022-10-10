class CreateReferralWalletRealizations < ActiveRecord::Migration
  def change
    create_table :referral_wallet_realizations do |t|
      t.references :referral_wallet, index: true
      t.references :order, index: true
      t.decimal :amount_used

      t.timestamps null: false
    end
    add_foreign_key :referral_wallet_realizations, :referral_wallets
    add_foreign_key :referral_wallet_realizations, :orders
  end
end
