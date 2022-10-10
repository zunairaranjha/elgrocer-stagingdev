class AdyenJob < ActiveJob::Base
  queue_as :partner_integration_queue

  def perform(command, order, original_reference = '')
    case command.downcase
    when 'auth_amount_changed'
      response = Adyenps::Checkout.amount_updates({
                                                    'modificationAmount' => { 'currency' => 'AED', 'value' => (order.total_price * 100).round },
                                                    'reference' => "O-#{order.card_detail['trans_ref']}-#{order.id}",
                                                    'originalReference' => order.merchant_reference,
                                                    'reason' => 'Order Amount Got Updated'
                                                  })
      Analytic.add_activity('Adyen:AdjustAuthorizationJob', order, response.to_json)
    when 'void_authorization'
      params = {
        originalReference: original_reference
      }
      response = Adyenps::Checkout.void_authorization(params.stringify_keys)
      Analytic.add_activity('Adyen:VoidAuthJob', order, response.to_json)
    end
  end

end
