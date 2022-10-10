# frozen_string_literal: true

module API
  module V1
    module Shoppers
      class DeleteShopper < Grape::API
        include TokenAuthenticable
        include OtpHelper
        version 'v1', using: :path
        format :json

        resource :shoppers do
          desc 'Delete Shopper'

          params do
            requires :phone_number, type: String, desc: 'Phone Number'
          end

          post '/deletion_otp' do
            error!(CustomErrors.instance.unauthorized, 421) unless current_shopper
            error!(CustomErrors.instance.phone_number_not_same, 421) if params[:phone_number].phony_normalized != current_shopper.phone_number

            phone_number = params[:phone_number].phony_normalized
            formatted_phone = "deletion_otp_#{phone_number}"
            otp_sent_count = otp_check_limit_get(formatted_phone, 'otp_sent_count').to_i
            is_blocked = otp_check_limits[:max_generate_otp] <= otp_sent_count
            error!(CustomErrors.instance.otp_attempts_limit, 421) if is_blocked

            otp = generate_unique_otp(formatted_phone)
            set_generated_otp(formatted_phone, otp)
            otp_check_limit_set(formatted_phone, 'otp_sent_count', otp_sent_count + 1)
            Sms::SmsNotification.new.send_sms(phone_number, I18n.t('message.account_deletion_otp', otp: otp))
            { message: 'ok' }
          end
        end
      end
    end
  end
end
