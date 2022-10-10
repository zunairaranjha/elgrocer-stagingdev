class RegisterNotificationsJob < ActiveJob::Base
  queue_as :default

  def perform(registration_id, device_type)
    if registration_id and device_type == 1
      AppleNotifications.unregister(registration_id)
      AppleNotifications.register(registration_id)
    elsif registration_id and device_type == 0
      GoogleMessaging.unregister(registration_id)
      GoogleMessaging.register(registration_id)
    end
  end
end
