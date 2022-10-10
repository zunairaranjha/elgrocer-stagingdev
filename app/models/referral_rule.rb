class ReferralRule < ActiveRecord::Base
	has_and_belongs_to_many :cities
	has_many :referral_wallets

  scope :active, -> { where(is_active: true) }

  def message
    if I18n.locale == :ar
      value = self.send("message_#{I18n.locale.to_s}")
    end
    value || read_attribute(:message)
  end

end
