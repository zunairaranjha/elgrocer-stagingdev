module OtpHelper
  def self.included(base)

    base.helpers do

      def generate_unique_otp(phone_number)
        otp = 0
        loop do
          otp = rand 1000..9999
          break unless otp == get_generated_otp(phone_number)
        end
        otp
      end

      def get_generated_otp(phone_number)
        (Redis.current.get phone_number).to_i
      end

      def set_generated_otp(phone_number, otp)
        Redis.current.set phone_number, otp, ex: 600
      end

      def otp_check_limit_set(phone_number, field, value)
        phone_otp_limit = Redis.current.get "#{phone_number}_otp_limit"
        phone_otp_limit = JSON(phone_otp_limit || '{}')
        phone_otp_limit[field] = value
        Redis.current.set "#{phone_number}_otp_limit", phone_otp_limit.to_json, ex: otp_check_limits[:phone_block_hours].hours
      end

      def otp_check_limit_get(phone_number, field)
        phone_otp_limit = JSON(Redis.current.get("#{phone_number}_otp_limit"))
        phone_otp_limit[field]
      end

      def otp_check_limits
        @system_config ||= SystemConfiguration.where(key: 'new_user_otp_limits').first&.value || '3-5-12'
        otp_limits = @system_config.split('-')
        { max_attempts: otp_limits[0].to_i, max_generate_otp: otp_limits[1].to_i, phone_block_hours: otp_limits[2].to_i }
      end
    end
  end
end


