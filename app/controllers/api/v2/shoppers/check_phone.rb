# frozen_string_literal: true

# require 'uri'
# require 'net/http'

module API
  module V2
    module Shoppers
      class CheckPhone < Grape::API
        version 'v2', using: :path
        format :json

        helpers do

          params :verify_phone_param do
            requires :phone_number, type: String, desc: "Shopper Phone Number"
          end

          params :verify_otp_param do
            requires :otp, type: Integer, desc: "Shopper entered OTP Number e.g 3495"
          end

          def generate_otp(phone_number)
            otp = 0
            loop do
              otp = rand 1000..9999
              break unless otp == get_otp(phone_number)
            end
            otp
          end

          def get_otp(phone_number)
            (Redis.current.get (phone_number)).to_i
          end

          def set_otp(phone_number, otp)
            Redis.current.set phone_number, otp, ex: 600
          end


          def phone_otp_limit_save(phone_number, field, value)
            phone_otp_limit = Redis.current.get "#{phone_number}_otp_limit"
            phone_otp_limit = JSON(phone_otp_limit ? phone_otp_limit : "{}")
            phone_otp_limit[field] = value
            Redis.current.set "#{phone_number}_otp_limit", phone_otp_limit.to_json, ex: new_user_otp_limits[:phone_block_hours].hours
          end

          def phone_otp_limit_get(phone_number, field)
            phone_otp_limit = JSON(Redis.current.get "#{phone_number}_otp_limit")
            phone_otp_limit[field]
          end

          def new_user_otp_limits
            @system_config ||= SystemConfiguration.where(key: 'new_user_otp_limits').first.value || "3-5-12"
            otp_limits = @system_config.split('-')
            { max_attempts: otp_limits[0].to_i, max_generate_otp: otp_limits[1].to_i, phone_block_hours: otp_limits[2].to_i }
          end
        end

        resource :shoppers do
          desc 'Check if shopper with provided phone Number is present.'
          params do
            requires :phone_number, type: String, desc: 'Phone Number'
          end

          #checks shopper with phone number, it already exists or not
          post '/check_phone' do
            already_exists = Shopper.exists?(phone_number: params[:phone_number]) ? 1 : 0
            {
              phoneNumber: params[:phone_number],
              userID: 1,
              is_phone_exists: already_exists,
              error: ''
            }
          end

          desc "Verify Phone Number of the Shopper."
          params do
            use :verify_phone_param
          end

          post '/verifyPhoneNumber' do
            phone_number = params[:phone_number].phony_normalized
            already_exists = Shopper.exists?(phone_number: phone_number) ? 1 : 0
            otp_sent_count = phone_otp_limit_get(phone_number, "otp_sent_count").to_i
            is_blocked = new_user_otp_limits[:max_generate_otp] > otp_sent_count ? false : true
            error!(CustomErrors.instance.phone_is_blocked, 421) if is_blocked
            if already_exists == 0 && !is_blocked
              otp = generate_otp(phone_number)
              Sms::SmsNotification.new.send_sms(phone_number, "#{otp} is your verification code for elGrocer UAE supermarket app.")
              phone_otp_limit_save(phone_number, "otp_sent_count", otp_sent_count+1)
              phone_otp_limit_save(phone_number, "otp_attempts", 0)
              set_otp(phone_number, otp)
            end
            { is_phone_exists: already_exists, is_blocked: is_blocked }
          end

          desc "Verify user's OTP"
          params do
            use :verify_phone_param
            use :verify_otp_param
          end

          post '/verifyOTP' do
            phone_number = params[:phone_number].phony_normalized
            otp_sent_count = phone_otp_limit_get(phone_number, "otp_sent_count").to_i
            is_blocked = new_user_otp_limits[:max_generate_otp] > otp_sent_count ? false : true
            error!(CustomErrors.instance.phone_is_blocked, 421) if is_blocked
            otp_attempts = phone_otp_limit_get(phone_number, "otp_attempts").to_i
            is_max_attempt_reached = new_user_otp_limits[:max_attempts] > otp_attempts ? false : true
            error!(CustomErrors.instance.phone_max_attempt_reached, 421) if is_max_attempt_reached
            if !is_max_attempt_reached && get_otp(params[:phone_number].phony_normalized) == params[:otp]
              {"message": "OTP is valid!"}
            else
              phone_otp_limit_save(phone_number, "otp_attempts", otp_attempts+1)
              error!(CustomErrors.instance.invalid_otp, 421)
            end
          end
          
        end
      end
    end
  end
end