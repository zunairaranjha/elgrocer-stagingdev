class AddRemainingCreditToReferralWallet < ActiveRecord::Migration
  def change
    add_column :referral_wallets, :remaining_credit, :decimal
  end
end
