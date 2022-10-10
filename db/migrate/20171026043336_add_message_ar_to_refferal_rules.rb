class AddMessageArToRefferalRules < ActiveRecord::Migration
  def change
  	add_column :referral_rules, :message_ar, :text
  end	
end
