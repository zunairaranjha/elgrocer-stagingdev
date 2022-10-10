namespace :shoppers do
  desc 'It generate and assign referral code to existing shoppers'
  task wallet_expiry_notify: :environment do
    Shopper.joins(:referral_wallets).where('referral_wallets.remaining_credit > 0 and referral_wallets.expire_date > ?', DateTime.now).distinct.each do |shopper|
      # puts "notifying #{shopper.name}"
      wallet = shopper.referral_wallets.available.take
      days_remaining = (wallet.expire_date - DateTime.now).round/1.day
      shopper.wallet_expiry_notify(wallet) if [wallet.referral_rule.expiry_days/2,7,2,1].include? days_remaining
      # distance_of_time_in_words(wallet.expire_date, DateTime.now)
      puts "Notifying, n: #{shopper.name}, wid: #{wallet.id}, a: #{wallet.remaining_credit}, rd: #{days_remaining}" if [wallet.referral_rule.expiry_days/2,7,2,1].include? days_remaining
      puts "Not notifying, n: #{shopper.name}, wid: #{wallet.id}, a: #{wallet.remaining_credit}, rd: #{days_remaining}" if !([wallet.referral_rule.expiry_days/2,7,2,1].include? days_remaining)
    end
  end
end
