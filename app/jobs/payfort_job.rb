class PayfortJob < ActiveJob::Base
  queue_as :default

  def perform(command, order = nil, credit_card = nil, merchant_reference = nil, amount = nil)
    Payfort::Payment.new(order).void_authorization(merchant_reference, amount) if command.downcase.eql?('void_authorization')
    Payfort::Payment.new(nil,nil, credit_card).update_card('INACTIVE') if command.downcase.eql?('inactive_card')
  end

end
