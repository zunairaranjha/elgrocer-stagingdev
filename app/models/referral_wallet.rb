class ReferralWallet < ActiveRecord::Base
  belongs_to :shopper, optional: true
  belongs_to :referral_rule, optional: true
  belongs_to :order, optional: true
  has_many :referral_wallet_realizations

  scope :available, -> { with_amount_used.where('expire_date > ?', DateTime.now).having('referral_wallets.amount - sum(coalesce(referral_wallet_realizations.amount_used,0.00)) > 0') }

  scope :expired, -> { with_amount_used.where('expire_date < ?', DateTime.now).having('referral_wallets.amount - sum(coalesce(referral_wallet_realizations.amount_used,0.00)) = 0') }

  scope :with_amount_used, -> {
    select("referral_wallets.*, round(sum(coalesce(referral_wallet_realizations.amount_used,0.0)),2) amount_used, referral_wallets.amount - round(sum(coalesce(referral_wallet_realizations.amount_used,0.00)),0) balance")
    .joins(' LEFT OUTER JOIN referral_wallet_realizations ON referral_wallet_realizations.referral_wallet_id = referral_wallets.id')
    .group("referral_wallets.id")
    .order('referral_wallets.expire_date')
  }

  def remaining_amount
    self.amount - referral_wallet_realizations.sum(:amount_used).to_f.round(2)
  end

  def is_expired?
    self.expire_date <= DateTime.now
  end

  def is_available?
    !is_expired? && remaining_amount > 0
  end

end
