# frozen_string_literal: true

module API
  module V1
    module Shoppers
      class Delete < Grape::API
        include TokenAuthenticable
        include OtpHelper
        version 'v1', using: :path
        format :json

        helpers do

          def get_otp(phone_number)
            (Redis.current.get "delete_shopper_#{phone_number}").to_i
          end
        end

        resource :shoppers do

          desc 'delete shopper account'

          params do
            requires :reason, type: String, desc: 'deletion reason'
            requires :otp, type: Integer, desc: 'shopper deletion otp'
          end

          post '/delete' do
            formatted_phone = "deletion_otp_#{current_shopper.phone_number.phony_normalized}"
            otp_attempt_count = otp_check_limit_get(formatted_phone, 'otp_attempts').to_i
            is_blocked = otp_check_limits[:max_attempts] <= otp_attempt_count
            error!(CustomErrors.instance.otp_attempts_limit, 421) if is_blocked
            unless get_generated_otp(formatted_phone) == params[:otp]
              otp_check_limit_set(formatted_phone, 'otp_attempts', otp_attempt_count + 1)
              error!(CustomErrors.instance.invalid_pin, 421)
            end
            Sms::SmsNotification.new.send_sms(current_shopper.phone_number, I18n.t('message.account_deletion_msg', current_date: Time.now.to_date))

            ShopperMailer.delete_account_email(current_shopper).deliver_now if current_shopper.email.present?

            user = {
              phone_number: Digest::MD5.hexdigest(current_shopper.phone_number + Time.now.to_s),
              name: Digest::MD5.hexdigest(current_shopper.name.to_s + Time.now.to_s),
              email: Digest::MD5.hexdigest(current_shopper.email.to_s + Time.now.to_s),
              password: 'deleted',
              encrypted_password: 'deleted',
              authentication_token: nil,
              is_deleted: true
            }
            Shopper.transaction do
              data = ShoppersDatum.find_or_initialize_by(shopper_id: current_shopper.id)
              data.update(detail: JSON({ deletion_reason: params[:reason], shopper_detail: current_shopper.attributes, deleted_at: Time.now }))
              Order.where(status_id: [-1, 0, 1, 8, 9, 12, 11], shopper_id: current_shopper.id).find_each do |order|
                order.update(status_id: 4, canceled_at: Time.now, user_canceled_type: 6)
              end
              current_shopper.credit_cards.where(is_deleted: false).update_all(is_deleted: true, updated_at: Time.now)
              current_shopper.orders.update_all(shopper_name: 'Deleted Shopper', shopper_phone_number: '+971000000000', shopper_deleted: true, updated_at: Time.now)
              current_shopper.shopper_addresses.update_all(shopper_name: 'Deleted Shopper', phone_number: '+971000000000',
                                                           address_name: 'Deleted Shopper', location_address: 'Deleted Shopper', street_address: 'Deleted Shopper')
              current_shopper.update!(user)
            end
            if current_shopper.is_deleted
              { message: I18n.t('message.shopper_deleted') }
            else
              error!(CustomErrors.instance.something_wrong, 421)
            end
          end
        end
      end
    end
  end
end
