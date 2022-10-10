class CreateReferralRules < ActiveRecord::Migration
  def change
    create_table :referral_rules do |t|
      t.string :name
      t.integer :expiry_days
      t.integer :referrer_amount
      t.integer :referee_amount
      t.integer :event_id
      t.text :message
      t.boolean :is_active

      t.timestamps null: false
    end
  end
end
