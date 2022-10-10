class ReferralWalletRealization < ActiveRecord::Base
  belongs_to :referral_wallet, optional: true
  belongs_to :order, optional: true
end
