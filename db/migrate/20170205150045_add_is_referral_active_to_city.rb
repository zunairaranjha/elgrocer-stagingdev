class AddIsReferralActiveToCity < ActiveRecord::Migration
  def change
    add_column :cities, :is_referral_active, :boolean
  end
end
