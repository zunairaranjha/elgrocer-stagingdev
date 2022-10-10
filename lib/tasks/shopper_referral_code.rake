namespace :shoppers do
  desc 'It generate and assign referral code to existing shoppers'
  task set_referral_code: :environment do
    Shopper.where(referral_code: nil).each do |shopper|
      shopper.update_columns(referral_code: shopper.ensure_referral_code)
    end
  end
end
