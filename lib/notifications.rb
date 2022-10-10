module Notifications
    module AppleNotifications
        def self.register(registration_id)
            ZeroPush.apns.register(registration_id)
        end

        def self.unregister(registration_id)
            ZeroPush.apns.unregister(registration_id)
        end

        def self.push(registration_id, info, alert=nil, badge=nil, sound='default', expiry=nil, content_available=nil, category=nil)
            params = {
                  "device_tokens": [registration_id],
                  "alert": alert,
                  "badge": badge,
                  "sound": sound,
                  "info": info
            }
            ZeroPush.apns.notify(params)
        end
    end

    module GoogleMessaging
        def self.register(registration_id)
            ZeroPush.gcm.register(registration_id)
        end

        def self.unregister(registration_id)
            ZeroPush.gcm.unregister(registration_id)
        end

        def self.push(registration_id, data, collapse_key=nil, delay_while_idle=nil, time_to_live=nil)
            params = {
                  "device_tokens": [registration_id],
                  "collapse_key": collapse_key,
                  "delay_while_idle": delay_while_idle,
                  "time_to_live": time_to_live,
                  "data": data
            }
            ZeroPush.gcm.notify(params)
        end
    end
end