require 'fcm'

class PushNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(registration_id, params, device_type, only_data = false)
    if device_type == 0 or device_type.eql?('android')
      params[:push_type] = params.delete(:message_type)
      GoogleMessaging.push(registration_id, params, nil, nil, nil, only_data)
    elsif device_type == 1 or device_type.eql?('ios')
      AppleNotifications.push(registration_id, params, params[:message])
    end

    # Pushwoosh.notify_devices(params[:message], [registration_id], params)
  end
end
