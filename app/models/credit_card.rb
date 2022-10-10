class CreditCard < ActiveRecord::Base
  belongs_to :shopper, optional: true
  has_many :orders

  # def self.unable_card(recurringDetailReference = nil,shopperReference = nil)
  #   CreditCard.find_by(trans_ref: recurringDetailReference, shopper_id: shopperReference).update(is_deleted: true)
  # end
  enum card_type: {
    '1' => 'visa',
    '2' => 'mc',
    '3' => 'american_express',
    '4' => 'dine_club',
    '5' => 'discover',
    '6' => 'jcb',
    '7' => 'visa_applepay',
    '8' => 'mc_applepay',
    '1001' => '1',
    '1002' => '2'
  }

  def self.create_credit_card(notiItem, is_deleted = false)
    card = CreditCard.find_or_initialize_by(trans_ref: notiItem[:additionalData][:"recurring.recurringDetailReference"])
    card.shopper_id = (notiItem[:additionalData][:shopperReference] || notiItem[:additionalData][:"recurring.shopperReference"]).to_i
    card.first6 = notiItem[:additionalData][:cardBin]
    card.last4 = notiItem[:additionalData][:cardSummary]
    card.card_type = notiItem[:paymentMethod]
    card.expiry_month, card.expiry_year = notiItem[:additionalData][:expiryDate].split('/')
    card.is_deleted = is_deleted
    card.save
    card
  end

end
