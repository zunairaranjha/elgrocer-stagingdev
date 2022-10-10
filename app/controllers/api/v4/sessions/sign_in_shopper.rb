# frozen_string_literal: true

module API
  module V4
    module Sessions
      class SignInShopper < Grape::API
        version 'v4', using: :path
        format :json

        #OTP helpers
        helpers do

          def generate_otp(phone_number)
            otp = 0
            loop do
              otp = rand 1000..9999
              break unless otp == get_otp(phone_number)
            end
            otp
          end

          def get_otp(phone_number)
            (Redis.current.get ("sign_in_sign_up_shopper_#{phone_number}")).to_i
          end

          def set_otp(phone_number, otp)
            Redis.current.set "sign_in_sign_up_shopper_#{phone_number}", otp, ex: new_user_otp_limits[:otp_expiry_seconds]
          end

          def phone_otp_limit_save(phone_number, field, value)
            phone_otp_limit = Redis.current.get "sign_in_sign_up_shopper_#{phone_number}_otp_limit"
            phone_otp_limit = JSON(phone_otp_limit ? phone_otp_limit : "{}")
            phone_otp_limit[field] = value
            Redis.current.set "sign_in_sign_up_shopper_#{phone_number}_otp_limit", phone_otp_limit.to_json, ex: new_user_otp_limits[:phone_block_time].seconds
          end

          def phone_otp_limit_get(phone_number, field)
            phone_otp_limit = JSON(Redis.current.get "sign_in_sign_up_shopper_#{phone_number}_otp_limit")
            if phone_otp_limit[field].nil?
              0
            else
              phone_otp_limit[field]
            end
          end

          def new_user_otp_limits
            @system_config ||= SystemConfiguration.where(key: 'new_smiles_user_otp_limits').first.value || "3-3-1800-180"
            otp_limits = @system_config.split('-')
            { max_attempts: otp_limits[0].to_i, max_generate_otp: otp_limits[1].to_i, phone_block_time: otp_limits[2].to_i, otp_expiry_seconds: otp_limits[3].to_i }
          end

          def is_valid_phone phone_number
            phone_number.match?(/\A\+\d{12}\z/)
          end
        end

        resource :sessions do
          desc "Authenticate Shopper and return shopper object with authentication token.
                Later the user is authenticated by the http header named Authentication-Token.",
               entity: API::V4::Sessions::Entities::SignInSmilesShopperEntity

          desc "Verify Phone Number of the Smiles Shopper."
          params do
            requires :phone_number, type: String, desc: "Shopper Phone Number"
          end
          post 'shopper/verify-phone' do
            error!(CustomErrors.instance.is_valid_phone, 421) unless is_valid_phone params[:phone_number]
            phone_number = params[:phone_number].phony_normalized
            # shopper = Shopper.find_by(phone_number: params[:phone_number])

            unless Shopper.where(phone_number: params[:phone_number]).exists?
              registered_shopper = ::Shoppers::RegisterSmiles.run(params)
              error!(registered_shopper.errors, 422) unless registered_shopper.valid?
            end

            otp_sent_count = phone_otp_limit_get(phone_number, "otp_sent_count").to_i
            is_blocked = new_user_otp_limits[:max_generate_otp] > otp_sent_count ? false : true
            error!(CustomErrors.instance.phone_is_blocked, 421) if is_blocked

            # if shopper.nil?
            #   registered_shopper = ::Shoppers::RegisterSmiles.run(params)
            #   error!(registered_shopper.errors, 422) unless registered_shopper.valid?
            # else
            #   otp_sent_count = phone_otp_limit_get(phone_number, "otp_sent_count").to_i
            #   is_blocked = new_user_otp_limits[:max_generate_otp] > otp_sent_count ? false : true
            #   error!(CustomErrors.instance.phone_is_blocked, 421) if is_blocked
            # end

            otp = generate_otp(phone_number)
            Sms::SmsNotification.new.send_sms(phone_number, "#{otp} is your verification code for elGrocer UAE supermarket app.")
            set_otp(phone_number, otp)
            phone_otp_limit_save(phone_number, "otp_sent_count", otp_sent_count + 1)
            phone_otp_limit_save(phone_number, "otp_attempts", 0)
            # user_platform_logs = UserPlatformLog.new(shopper_id: shopper.id)
            # if request.headers["App-Agent"].split('.')[1] == "elgrocer"
            #   user_platform_logs.platform_type = 0
            # elsif request.headers["App-Agent"].split('.')[1] == "smile"
            #   user_platform_logs.platform_type = 1
            # end
            # user_platform_logs.save
            { otp_sent: true, is_blocked: is_blocked }
          end

          desc "Verify shopper's OTP"
          params do
            requires :phone_number, type: String, desc: "Shopper Phone Number"
            requires :otp, type: Integer, desc: "Shopper entered OTP Number e.g 3495"
            optional :registration_id, type: String, desc: "Shopper's registration_id"
            optional :device_type, type: Integer, desc: "Shopper's device type (0 - Android, 1 - IOS)"
          end
          post 'shopper/signin-with-otp' do
            error!(CustomErrors.instance.is_valid_phone, 421) unless is_valid_phone params[:phone_number]
            phone_number = params[:phone_number].phony_normalized
            shopper = Shopper.find_by(phone_number: params[:phone_number])
            error!(CustomErrors.instance.shopper_not_found, 403) if shopper.nil?

            # otp_sent_count = phone_otp_limit_get(phone_number, "otp_sent_count").to_i
            # is_blocked = new_user_otp_limits[:max_generate_otp] > otp_sent_count ? false : true
            # error!(CustomErrors.instance.phone_is_blocked, 421) if is_blocked
            otp_attempts = phone_otp_limit_get(phone_number, "otp_attempts").to_i
            # is_max_attempt_reached = new_user_otp_limits[:max_attempts] > otp_attempts ? false : true
            error!(CustomErrors.instance.phone_max_attempt_reached, 421) if new_user_otp_limits[:max_attempts] < otp_attempts

            if get_otp(params[:phone_number].phony_normalized) == params[:otp]
              # device_type = Shopper.device_types["smiles_sdk"]
              device_type = params[:device_type]
              platform_type = Shopper.platform_types['elgrocer']
              shopper.login(params[:registration_id], device_type, request.headers['Datetimeoffset'].to_s, platform_type: platform_type)
              Redis.current.del("sign_in_sign_up_shopper_#{phone_number}_otp_limit")
              UserPlatformLog.add_logs(shopper)
              present shopper, with: API::V4::Sessions::Entities::SignInSmilesShopperEntity
            else
              phone_otp_limit_save(phone_number, "otp_attempts", otp_attempts + 1)
              error!(CustomErrors.instance.invalid_otp, 421)
            end
          end
        end
      end
    end
  end
end