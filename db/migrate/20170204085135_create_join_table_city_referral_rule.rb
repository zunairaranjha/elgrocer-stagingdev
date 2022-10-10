class CreateJoinTableCityReferralRule < ActiveRecord::Migration
  def change
    create_join_table :cities, :referral_rules do |t|
      # t.index [:city_id, :referral_rule_id]
      # t.index [:referral_rule_id, :city_id]
    end
  end
end
