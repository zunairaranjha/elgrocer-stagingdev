module API
  module V1
    module Smiles
      class SmilesLoyalty < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :smiles do

          #==================== Account Pin =======================#
          desc 'Smiles Account Pin'
          params do
          end

          post '/account_pin' do
            error!(CustomErrors.instance.otp_attempts_limit) if current_shopper.shoppers_datum.present? && current_shopper.shoppers_datum.detail['smiles_retry_otp_attempts_blocked']
            ShoppersDatum.increment_smiles_otp_attempts(current_shopper.id, 'smiles_retry_otp_attempts')
            res = account_pin
            if res['accountPinResponse']['ackMessage']['status'] == 'SUCCESS'
              Redis.current.set "smiles-pin-#{current_shopper.smiles_phone_format}", res['accountPinResponse']['pin'], ex: 300
              { message: 'ok'}
            elsif res['accountPinResponse']['ackMessage']['errorCode'] == 'TIB-Loyalty-4305'
              enroll_smiles_member
            elsif res['accountPinResponse']['ackMessage']['errorCode'] == 'TIB-Loyalty-4316'
              activate_smiles_account
            else
              error!(CustomErrors.instance.send(res['accountPinResponse']['ackMessage']['errorCode'].underscore), 421)  rescue error!(res['accountPinResponse']['ackMessage']['errorDescription'], 421)
            end
          end

          #==================== Login Smiles Account ====================#

          desc 'Smiles Account Login'

          params do
            requires :pin, type: String, desc: 'Account Pin', documentation: { example: '12345' }
          end

          post '/login' do
            error!(CustomErrors.instance.otp_attempts_limit) if current_shopper.shoppers_datum.detail['smiles_invalid_otp_attempts_blocked']
            pin = verify_otp(params[:pin])
            do_smiles_login(pin)
          end

          #==================== Get Smiles Member Info ====================#

          desc 'Smiles member Info'
          params do
            optional :order_id, type: Integer, desc: 'Order Id', documentation: { example: 234567890 }
            optional :loyalty_id, type: String, desc: 'Loyalty Id', documentation: { example: "234567890" }
          end

          get '/member_info' do
            error!(CustomErrors.instance.loyalty_sign_in, 421) unless current_shopper.is_smiles_user || request.headers['Loyalty-Id'].present?
            # Loyalty::Smiles.new.smiles_auth unless Redis.current.get('smiles_access_token').present?
            # res = JSON(Loyalty::Smiles.new.get_smiles_member_info(current_shopper.smiles_phone_format).body)
            # puts "Hereeeeeee12345678"
            # puts res
            # if res['getMemberResponse']['ackMessage']['status'] == 'SUCCESS'
            #   ut = current_shopper.unique_smiles_token.split('$')
            #   if ut[0] == res['getMemberResponse']['accountsInfo'][0]['loyaltyId'] && ut[1] == current_shopper.registration_id && res['getMemberResponse']['accountsInfo'][0]['accountStatus'] == 'Active'
            #     Redis.current.set "smiles_member_info_#{current_shopper.id}", res.to_json, ex: 900
            #     burn_points = OrdersDatum.find_by(order_id: params[:order_id])&.detail.to_h['transaction_ref_ids'].to_h.values.sum if params[:order_id].to_i.positive?
            #     present res, with: API::V1::Smiles::Entities::MemberInfoEntity, burn_points: burn_points
            #   else
            #     Redis.current.del "smiles_member_info_#{current_shopper.id}"
            #     error!(CustomErrors.instance.loyalty_sign_in, 421)
            #   end
            # else
            #   error!(CustomErrors.instance.send(res['getMemberResponse']['ackMessage']['errorCode'].underscore), 421)  rescue error!(res['getMemberResponse']['ackMessage']['errorDescription'], 421)
            # end
            get_member_info
          end


          #==================== Get Smiles Member Info from cache ====================#

          desc 'Smiles member Info cache'
          params do
            optional :loyalty_id, type: String, desc: 'Loyalty Id', documentation: { example: "234567890" }
          end

          get '/member_info_cache' do
            error!(CustomErrors.instance.loyalty_sign_in, 421) unless current_shopper.is_smiles_user || request.headers['Loyalty-Id'].present?
            res = Redis.current.get "smiles_member_info_#{current_shopper.id}"
            if res.present?
              present JSON(res), with: API::V1::Smiles::Entities::MemberInfoEntity
            else
              # Loyalty::Smiles.new.smiles_auth unless Redis.current.get('smiles_access_token').present?
              # res = JSON(Loyalty::Smiles.new.get_smiles_member_info(current_shopper.smiles_phone_format).body)
              # if res['getMemberResponse']['ackMessage']['status'] == 'SUCCESS'
              #   ut = current_shopper.unique_smiles_token.split('$')
              #   if ut[0] == res['getMemberResponse']['accountsInfo'][0]['loyaltyId'] && ut[1] == current_shopper.registration_id && res['getMemberResponse']['accountsInfo'][0]['accountStatus'] == 'Active'
              #     Redis.current.set "smiles_member_info_#{current_shopper.id}", res.to_json, ex: 900
              #     present res, with: API::V1::Smiles::Entities::MemberInfoEntity
              #   else
              #     error!(CustomErrors.instance.loyalty_sign_in, 421)
              #   end
              # else
              #   error!(CustomErrors.instance.send(res['getMemberResponse']['ackMessage']['errorCode'].underscore), 421)  rescue error!(res['getMemberResponse']['ackMessage']['errorDescription'], 421)
              # end
              get_member_info
            end
          end

          #==================== Get Smiles Transaction History ====================#

          desc 'Smiles member Transactions History'
          params do
            requires :limit, type: Integer, desc: 'Limit', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset', documentation: { example: 10 }
          end

          get '/smiles_transaction_history' do
            result = SmilesTransactionLog.where(shopper_id: current_shopper.id).order(created_at: :desc)
            result = result.limit(params[:limit].to_i + 1).offset(params[:offset].to_i)
            is_next = result.length > params[:limit].to_i
            result = result.to_a.first(params[:limit].to_i)
            new_result = {next: is_next, transactions: result }
            present new_result, with: API::V1::Smiles::Entities::SmilesTransactionPaginationEntity
          end

        end

        helpers do

          #=============================== Smiles Account Pin =============================================#

          def account_pin
            Loyalty::Smiles.new.smiles_auth unless Redis.current.get('smiles_access_token').present?
            JSON(Loyalty::Smiles.new.smiles_account_pin(current_shopper.smiles_phone_format).body)
          end

          #=============================== Smiles Login Helper =============================================#

          def do_smiles_login(pin)
            Loyalty::Smiles.new.smiles_auth unless Redis.current.get('smiles_access_token').present?
            req = { phone_number: current_shopper.smiles_phone_format, pin: pin}
            res = JSON(Loyalty::Smiles.new.smiles_login(req).body)
            if res['loginResponse']['ackMessage']['status'] == 'SUCCESS'
              current_shopper.shoppers_datum.reset_smiles_otp_attempts
              info = get_shopper_smiles_info
              current_shopper.smiles_loyalty_id = info['getMemberResponse']['accountsInfo'][0]['loyaltyId']
              current_shopper.unique_smiles_token = "#{info['getMemberResponse']['accountsInfo'][0]['loyaltyId']}$#{current_shopper.registration_id}"
              current_shopper.is_smiles_user = true
              current_shopper.save
              { message: 'ok' }
            else
              # ShoppersDatum.increment_smiles_otp_attempts(current_shopper.id, 'smiles_invalid_otp_attempts')
              error!(CustomErrors.instance.send(res['loginResponse']['ackMessage']['errorCode'].underscore), 421)  rescue error!(res['loginResponse']['ackMessage']['errorDescription'], 421)
            end
          end

          #=============================== Enroll Smiles Member Helper =============================================#

          def enroll_smiles_member
            req = {
              phone_number: current_shopper.smiles_phone_format,
              device_id: current_shopper.registration_id,
              email: current_shopper.email
            }
            is_success = false
            response = JSON(Loyalty::Smiles.new.smiles_enroll_member(req).body)
            if response['enrollMemberResponse']['ackMessage']['status'] == 'SUCCESS'
              is_success = true
              res = account_pin
              if res['accountPinResponse']['ackMessage']['status'] == 'SUCCESS'
                Redis.current.set "smiles-pin-#{current_shopper.smiles_phone_format}", res['accountPinResponse']['pin'], ex: 120
                { message: 'ok'}
              else
                error!(CustomErrors.instance.send(res['accountPinResponse']['ackMessage']['errorCode'].underscore), 421)  rescue error!(res['accountPinResponse']['ackMessage']['errorDescription'], 421)
              end
            end
            send_registration_log(response, is_success)
            return if is_success

            error!(CustomErrors.instance.send(response['enrollMemberResponse']['ackMessage']['errorCode'].underscore), 421)  rescue error!(response['enrollMemberResponse']['ackMessage']['errorDescription'], 421)
          end

          #=============================== Activate Smiles Account Method =============================================#

          def activate_smiles_account
            response = JSON(Loyalty::Smiles.new.smiles_activate_account(current_shopper.smiles_phone_format).body)
            if response['activateAccountsResponse']['ackMessage']['status'] == 'SUCCESS'
              res = account_pin
              if res['accountPinResponse']['ackMessage']['status'] == 'SUCCESS'
                Redis.current.set "smiles-pin-#{current_shopper.smiles_phone_format}", res['accountPinResponse']['pin'], ex: 120
                { message: 'ok'}
              else
                error!(CustomErrors.instance.send(res['accountPinResponse']['ackMessage']['errorCode'].underscore), 421)  rescue error!(res['accountPinResponse']['ackMessage']['errorDescription'], 421)
              end
            else
              error!(CustomErrors.instance.send(response['activateAccountsResponse']['ackMessage']['errorCode'].underscore), 421)  rescue error!(response['activateAccountsResponse']['ackMessage']['errorDescription'], 421)
            end
          end

          #============================== Verify OTP =====================================================#

          def verify_otp(pin)
            error!(CustomErrors.instance.otp_expired, 421) unless (Redis.current.get "smiles-pin-#{current_shopper.smiles_phone_format}").present?
            cipher = OpenSSL::Cipher::AES128.new(:CBC)
            cipher.key = ENV['SMILES_KEY']
            cipher.iv = ENV['SMILES_IV']
            d_value = Base64.decode64(Redis.current.get "smiles-pin-#{current_shopper.smiles_phone_format}")
            decrypted_plain_text = cipher.update(d_value) + cipher.final
            if decrypted_plain_text == pin
              Redis.current.get "smiles-pin-#{current_shopper.smiles_phone_format}"
            else
              ShoppersDatum.increment_smiles_otp_attempts(current_shopper.id, 'smiles_invalid_otp_attempts')
              error!(CustomErrors.instance.invalid_pin, 421)
            end
          end

          #==================== Smiles Member Info ======================#
          def get_shopper_smiles_info
            response = Loyalty::Smiles.new.get_smiles_member_info(current_shopper.smiles_phone_format)
            res = JSON(response.body)
            if res['getMemberResponse']['ackMessage']['status'] == 'SUCCESS'
              res
            else
              error!(CustomErrors.instance.send(res['getMemberResponse']['ackMessage']['errorCode'].underscore), 421) rescue error!(response['getMemberResponse']['ackMessage']['errorDescription'], 421)
            end
          end

          #==================== Partner Registration Logs, If new user registered to Smiles ======================#

          def send_registration_log(response, is_success)
            sr = ShopperRegistrationLog.new
            sr.shopper_id = current_shopper.id
            sr.owner = Partner.find_by_name('smile_data')
            sr.partner_name = 'Smiles'
            sr.details[:response] = response
            sr.success = is_success
            sr.save
          end

          #==================== Get Member Info =================================#
          def get_member_info
            Loyalty::Smiles.new.smiles_auth unless Redis.current.get('smiles_access_token').present?
            # res = JSON(Loyalty::Smiles.new.get_smiles_member_info(current_shopper.smiles_phone_format).body)
            response = Loyalty::Smiles.new.get_smiles_member_info(current_shopper.smiles_phone_format)
            error!(CustomErrors.instance.server_error, 421) if response.status == 500
            res = JSON(response.body)
            if SUCCESSFUL_HTTP_STATUS.include?(response.status)
              ut = current_shopper.unique_smiles_token.to_s.split('$')
              if (ut[0] == res['getMemberResponse']['accountsInfo'][0]['loyaltyId'] && ut[1] == current_shopper.registration_id && res['getMemberResponse']['accountsInfo'][0]['accountStatus'] == 'Active') || (request.headers['Loyalty-Id'].to_s == current_shopper.smiles_loyalty_id)
                cal_and_show_member_info(res)
              elsif request.headers['Loyalty-Id'].present? && request.headers['Loyalty-Id'].to_s != current_shopper.smiles_loyalty_id
                smiles_loyalty_login
              else
                Redis.current.del "smiles_member_info_#{current_shopper.id}"
                error!(CustomErrors.instance.loyalty_sign_in, 421)
              end
            elsif request.headers['Loyalty-Id'].present?
              smiles_loyalty_login
            else
              error!(CustomErrors.instance.send(res['getMemberResponse']['ackMessage']['errorCode'].underscore), 421)  rescue error!(res['getMemberResponse']['ackMessage']['errorDescription'], 421)
            end
          end

          def smiles_loyalty_login
            response = Loyalty::Smiles.new.sdk_smiles_login(request.headers['Loyalty-Id'])
            error!(CustomErrors.instance.server_error, 421) if response.status == 500
            res = JSON(response.body)
            if SUCCESSFUL_HTTP_STATUS.include?(response.status)
              current_shopper.smiles_loyalty_id = request.headers['Loyalty-Id']
              current_shopper.save
              response = Loyalty::Smiles.new.get_smiles_member_info(current_shopper.smiles_phone_format)
              error!(CustomErrors.instance.server_error, 421) if response.status == 500
              res = JSON(response.body)
              if SUCCESSFUL_HTTP_STATUS.include?(response.status)
                cal_and_show_member_info(res)
              else
                error!(CustomErrors.instance.send(res['getMemberResponse']['ackMessage']['errorCode'].underscore), 421)  rescue error!(res['getMemberResponse']['ackMessage']['errorDescription'], 421)
              end
            else
              error!(CustomErrors.instance.send(res['loginResponse']['ackMessage']['errorCode'].underscore), 421)  rescue error!(res['loginResponse']['ackMessage']['errorDescription'], 421)
            end
          end

          def cal_and_show_member_info(res)
            # update_shopper_info(res)
            Redis.current.set "smiles_member_info_#{current_shopper.id}", res.to_json, ex: 900
            burn_points = OrdersDatum.find_by(order_id: params[:order_id])&.detail.to_h['transaction_ref_ids'].to_h.values.sum if params[:order_id].to_i.positive?
            present res, with: API::V1::Smiles::Entities::MemberInfoEntity, burn_points: burn_points
          end

          def update_shopper_info(res)
            # shopper_datum = current_shopper.shoppers_datum
            shopper_datum = ShoppersDatum.find_or_initialize_by(shopper_id: current_shopper.id)
            # shopper_datum.detail.merge!('smiles_tier_level': res['getMemberResponse']['accountsInfo'][0]['tierLevel'], 'food_subscription_status': res['getMemberResponse']['accountsInfo'][0]['foodSubscriptionStatus'])
            shopper_datum.detail.merge!('smiles_tier_level': res['getMemberResponse']['accountsInfo'][0]['tierLevel'], 'food_subscription_status': false)
            shopper_datum.save
          end
        end
      end
    end
  end
end