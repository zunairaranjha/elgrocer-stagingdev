# frozen_string_literal: true

module GoogleMessaging
  # def self.register(registration_id)
  #   ZeroPush.gcm.register(registration_id)
  # end
  #
  # def self.unregister(registration_id)
  #   ZeroPush.gcm.unregister(registration_id)
  # end

  def self.push(registration_id, data, collapse_key = nil, delay_while_idle = nil, time_to_live = nil, only_data = false)
    notification = { title: data[:message] || data[:title] }
    params = {
      # "device_tokens": [registration_id],
      # "collapse_key": collapse_key,
      # "delay_while_idle": delay_while_idle,
      # "time_to_live": time_to_live,
      "data": data
    }
    params[:notification] = notification unless only_data
    # ZeroPush.gcm.notify(params)
    gcm = FCM.new(ENV['GOOGLE_API_KEY_PUSH'])
    fcm = FCM.new(ENV['GOOGLE_API_KEY_PUSH_2'])
    fcm_picker = FCM.new(ENV['GOOGLE_API_KEY_PUSH_PICKER'])
    # options = {data: params, collapse_key: "elGrocerUpdates"}
    # gcm.send([registration_id], params)
    gcm.send(registration_id, params)
    fcm.send(registration_id, params)
    fcm_picker.send(registration_id, params)
  end
end
