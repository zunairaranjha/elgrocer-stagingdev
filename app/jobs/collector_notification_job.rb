class CollectorNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(order_id)
    order = Order.find_by(id: order_id)
    if order&.retailer_service_id == 2 and order.status_id != 4
      remind_collector = SystemConfiguration.find_by(key: 'remind_collector')
      time_dif = order.estimated_delivery_at - Time.now
      if (time_dif > 0) and (time_dif < Integer(remind_collector&.value || 30)*60)
        subs_link = Firebase::LinkShortener.new.order_pending_collection_link(order.id, order.shopper_id)
        subs_link = "https://elgrocershopper.page.link/?link=http%3A%2F%2Felgrocer.com%2Forders%3Fshopper_id%3D#{order.shopper_id}%26order_id%3D#{order.id}&apn=com.el_grocer.shopper&isi=1040399641&ibi=elgrocer.com.ElGrocerShopper" unless subs_link
        
        if order.order_collection_detail.collector_detail_id
          collector_phone = order.collector_detail.phone_number
          collector_phone = collector_phone.length > 10 ? collector_phone.phony_formatted(format: :+, spaces: '') : collector_phone.phony_normalized
          SmsNotificationJob.perform_later(collector_phone, I18n.t("sms.collection_pending_sms", subs_link: subs_link))
        end
        SmsNotificationJob.perform_later(order.shopper_phone_number.phony_normalized, I18n.t("sms.collection_pending_sms", subs_link: subs_link))
        params = {
          'message': I18n.t("push_message.message_109") ,
          'order_id': order_id,
          'message_type': 109,
          'shopper_id': order.shopper_id
        }
        shopper = order.shopper
        PushNotificationJob.perform_later(shopper.registration_id, params, shopper.device_type)
      end
    end
  end
end