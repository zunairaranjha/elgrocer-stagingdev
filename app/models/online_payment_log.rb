class OnlinePaymentLog < ActiveRecord::Base
  attr_accessor :refund_amount
  belongs_to :order, optional: true

  def display_name
    "OnlinePaymentLog # #{id}"
  end

  def self.add_activity(order, response = nil)
    begin
      OnlinePaymentLog.create(method: response['command'], order_id: order.id, status: response['response_message'].downcase, merchant_reference: response['merchant_reference'], amount: (response['amount'].to_i / 100.0), fort_id: response['fort_id'])
    rescue => e
    end
  end

  def self.add_adyen_activity(order, res = nil)
    begin
      opl = OnlinePaymentLog.find_or_initialize_by(order_id: order.id, fort_id: res['pspReference'])
      opl.merchant_reference = res['originalReference'] || res['merchantReference']
      opl.method = res['eventCode']
      opl.authorization_code = res['additionalData']['authCode'] if res['eventCode'].eql?('AUTHORISATION')
      opl.status = res['success'].to_s.eql?('true') ? 'success' : res['reason']
      opl.amount = res['amount']['value'].to_i / 100.0
      opl.save rescue e
      # res = response["notificationItems"][0]["NotificationRequestItem"]
    #   OnlinePaymentLog.create(method: res['eventCode'], order_id: order.id,
    #                           status: res['success'] ? 'success' : res['reason'],
    #                           merchant_reference: res['originalReference'] || res['merchantReference'],
    #                           amount: (res['amount']['value'].to_i / 100.0), fort_id: res['pspReference'])
    # rescue => e
    end
  end

end
