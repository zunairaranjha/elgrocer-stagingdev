class RetailerOperator < ActiveRecord::Base
  # include RegisterNotifications

  belongs_to :retailer, optional: true

  enum device: {
        android: 0,
        ios: 1
    }

  def device
    case device_type
    when 0
      'Android'
    when 1
      'IOS'
    else
      ''
    end
  end

  def update_profile_notify
    if self.registration_id
      params = {
        'message': I18n.t("message.profile_update"),
        'message_type': 0,
        'retailer_id': self.retailer.id
      }

      push_notification(self.registration_id, params, device_type)
    end
  end

  def new_order_notify(order_id)
    if self.registration_id
      params = {
        'message': I18n.t("message.new_order_notify"),
        'order_id': order_id,
        'delivery_type_id': Order.find(order_id).delivery_type_id,
        'message_type': 2,
        'retailer_id': self.retailer.id
      }

      push_notification(self.registration_id, params, device_type)
    end
  end

  def update_order_notify(update_type_str, order_id)
    if self.registration_id
      params = {
        'message': I18n.t("message.retailer_order_notify",update_type_str: update_type_str) ,
        'order_id': order_id,
        'message_type': 4,
        'retailer_id': self.retailer.id
      }

      push_notification(self.registration_id, params, device_type)
    end
  end

  def cancel_order_notify(order_id)
    if self.registration_id
      params = {
        'message': '',
        'order_id': order_id,
        'message_type': 5,
        'retailer_id': self.retailer.id
      }

      push_notification(self.registration_id, params, device_type)
    end
  end

  def approve_order_notify(order_id)
    if self.registration_id
      params = {
        'message': I18n.t("message.new_order_notify"),
        'order_id': order_id,
        'message_type': 1,
        'retailer_id': self.retailer.id
      }

      push_notification(self.registration_id, params, device_type)
    end
  end

  def selecting_products_notify(order_id)
    if self.registration_id
      params = {
        'message': I18n.t("message.selecting_products_notify"),
        'order_id': order_id,
        'message_type': 6,
        'retailer_id': self.retailer.id
      }

      push_notification(self.registration_id, params, device_type)
    end
  end

  def selected_products_notify(order_id)
    if self.registration_id
      params = {
        'message': I18n.t("message.selected_products_notify"),
        'order_id': order_id,
        'message_type': 7,
        'retailer_id': self.retailer.id
      }

      push_notification(self.registration_id, params, device_type)
    end
  end

  def edit_order_notify(order_id)
    if self.registration_id
      params = {
          'message': "User put order #{order_id} in edit!",
          'order_id': order_id,
          'message_type': 81,
          'retailer_id': self.retailer.id
      }

      push_notification(self.registration_id, params, device_type)
    end
  end

  def pending_order_notify(order_id)
    if self.registration_id
      params = {
          'message': "User put order #{order_id} in pending again!",
          'order_id': order_id,
          'message_type': 82,
          'retailer_id': self.retailer.id
      }

      push_notification(self.registration_id, params, device_type)
    end
  end

  def welcome_notify
    if self.registration_id
      params = {
        'message':  I18n.t("message.hello"),
        'message_type': 3,
        'retailer_id': self.retailer.id
      }

      push_notification(self.registration_id, params, device_type)
    end
  end

  def select_order_notify(order_id,hardware_id)
    if self.registration_id
      params = {
        'message': "Order has been selected" ,
        'order_id': order_id,
        'hardware_id': hardware_id,
        'message_type': 41,
        'retailer_id': self.retailer.id
      }

      push_notification(self.registration_id, params, device_type)
    end
  end

  def unselect_order_notify(order_id,hardware_id)
    if self.registration_id
      params = {
        'message': "Order has been unselected" ,
        'order_id': order_id,
        'hardware_id': hardware_id,
        'message_type': 42,
        'retailer_id': self.retailer.id
      }

      push_notification(self.registration_id, params, device_type)
    end
  end

  def online_payment_failed_notify(order_id)
    if self.registration_id
      params = {
          'message': I18n.t("message.online_payment_failed"),
          'order_id': order_id,
          'message_type': 70,
          'retailer_id': self.retailer.id
      }

      push_notification(self.registration_id, params, device_type)
    end
  end

  def delete_push_token
    # UnregisterNotificationsJob.perform_later(self.registration_id, self.device_type) if registration_id
    self.destroy
  end

  private

  def push_notification(registration_id, params, device_type)
    PushNotificationJob.perform_later(registration_id, params, device_type, true)
  end
end
