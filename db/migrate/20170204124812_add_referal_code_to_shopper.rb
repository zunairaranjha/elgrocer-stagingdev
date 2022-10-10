class AddReferalCodeToShopper < ActiveRecord::Migration
  def change
    add_column :shoppers, :referral_code, :string
    add_column :shoppers, :referred_by, :integer, :null => true, :index => true

    Rake::Task['shoppers:set_referral_code'].invoke
  end
end
