module RegisterNotifications
  def register
    RegisterNotificationsJob.perform_later(self.registration_id, self.device_type)
  end
end
