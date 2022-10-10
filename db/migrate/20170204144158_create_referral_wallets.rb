class CreateReferralWallets < ActiveRecord::Migration
  def change
    create_table :referral_wallets do |t|
      t.references :shopper, index: true
      t.integer :amount
      t.datetime :expire_date
      t.string :info
      t.references :referral_rule, index: true
      t.references :order, index: true

      t.timestamps null: false
    end
    add_foreign_key :referral_wallets, :shoppers
    add_foreign_key :referral_wallets, :referral_rules
    add_foreign_key :referral_wallets, :orders
  end
end
