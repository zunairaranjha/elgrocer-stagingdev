# require 'houston'

# module AppleNotifications
#     def self.register(registration_id)
#         ZeroPush.apns.register(registration_id)
#     end

#     def self.unregister(registration_id)
#         ZeroPush.apns.unregister(registration_id)
#     end

#     def self.push(registration_id, info, alert=nil, badge=nil, sound='default', expiry=nil, content_available=nil, category=nil)
#         params = {
#               "device_tokens": [registration_id],
#               "alert": alert,
#               "badge": badge,
#               "sound": sound,
#               "info": info
#         }
#         setting = Setting.select(:id, :apn_certificate).first
#         # if Setting.first && Setting.first.apn_certificate.present?
#         if setting&.apn_certificate.present?
#           apn = Rails.env.production? ? Houston::Client.production : Houston::Client.development
#           # apn.certificate = File.read(Rails.public_path + 'Certificates.pem')
#           # apn.certificate = Setting.first.apn_certificate
#           apn.certificate = setting.apn_certificate
#           params[:device] = registration_id
#           notification = Houston::Notification.new(params)
#           # notification.category = 'INVITE_CATEGORY'
#           # notification.content_available = true
#           # notification.mutable_content = true
#           notification.custom_data = info
#           apn.push(notification)
#         else
#           # ZeroPush.apns.notify(params)
#         end
#     end
# end

# require 'apnotic'

module AppleNotifications
  def self.push(registration_id, info, alert, badge: nil, sound: 'default', expiry: nil, content_available: nil, category: nil)
    apn_params = SystemConfiguration.where("key ilike 'apn.%'").order(:key)
    connection = if Rails.env.production?
                   Apnotic::Connection.new(auth_method: :token, cert_path: StringIO.new(apn_params[0].value.gsub('\n', "\n")),
                                           key_id: apn_params[1].value, team_id: apn_params[2].value)
                 else
                   Apnotic::Connection.development(auth_method: :token, cert_path: StringIO.new(apn_params[0].value.gsub('\n', "\n")),
                                                   key_id: apn_params[1].value, team_id: apn_params[2].value)
                 end
    notification = Apnotic::Notification.new(registration_id)
    notification.alert = alert
    notification.custom_payload = info
    notification.topic = apn_params[-1].value
    response = connection.push(notification)
    connection.close
    response
  end
end
