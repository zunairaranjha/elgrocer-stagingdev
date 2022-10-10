# frozen_string_literal: true
require 'faraday/httpclient'
module Loyalty
  class Smiles

    def request_headers
      smiles_auth unless Redis.current.get('smiles_access_token').present?
      {
        'Authorization' => Redis.current.get('smiles_access_token'),
        'clientId' => ENV['SMILES_CLIENT_ID'],
        'X-TIB-RequestedDate' => Time.now.strftime('%d-%m-%Y %H:%M:%S'),
        'X-TIB-RequestedSystem' => ENV['SMILES_REQUESTED_SYSTEM'],
        'X-TIB-TransactionID' => (Time.now.to_f * 10000000).round.to_s,
        'accept' => 'application/json',
        'content-type' => 'application/json',
        'Origin' => 'https://api.elgrocer.com'
      }
    end

    def request_headers_sdk
      smiles_auth_sdk unless Redis.current.get('smiles_access_token_sdk').present?
      {
        'Authorization' => Redis.current.get('smiles_access_token_sdk'),
        'clientId' => ENV['SMILES_CLIENT_ID_SDK'],
        'X-TIB-RequestedDate' => Time.now.strftime('%d-%m-%Y %H:%M:%S'),
        'X-TIB-RequestedSystem' => ENV['SMILES_REQUESTED_SYSTEM'],
        'X-TIB-TransactionID' => (Time.now.to_f * 10000000).round.to_s,
        'accept' => 'application/json',
        'content-type' => 'application/json',
        'Origin' => 'https://api.elgrocer.com'
      }
    end

    def smiles_auth
      headers = {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
      params = {
        'grant_type' => 'client_credentials',
        'scope' => 'apioauth',
        'client_id' => ENV['SMILES_CLIENT_ID'],
        'client_secret' => ENV['SMILES_CLIENT_SECRET']
      }

      response = send_request(SMILES_AUTH_URL, params, headers)
      res = JSON(response.body)
      Redis.current.set 'smiles_access_token', "#{res['token_type']} #{res['access_token']}", ex: res['expires_in']
      Redis.current.set 'smiles_transaction_id', response.headers['x-global-transaction-id'], ex: res['expires_in']
      PartnerOauthToken.create_log('Smiles Token', res)
      response
    end

    def smiles_auth_sdk
      headers = {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
      params = {
        'grant_type' => 'client_credentials',
        'scope' => 'apioauth',
        'client_id' => ENV['SMILES_CLIENT_ID_SDK'],
        'client_secret' => ENV['SMILES_CLIENT_SECRET_SDK']
      }

      response = send_request(SMILES_AUTH_URL_SDK, params, headers)
      res = JSON(response.body)
      Redis.current.set 'smiles_access_token_sdk', "#{res['token_type']} #{res['access_token']}", ex: res['expires_in']
      PartnerOauthToken.create_log('Smiles Token', res)
      response
    end

    def smiles_account_pin(phone_number)
      params = {
        "accountPinRequest": {
          "accountNumber": phone_number
        }
      }.to_json

      response = send_request(SMILES_ACCOUNT_PIN_PATH, params, request_headers)
      response
    end

    def smiles_login(req)
      params = {
        "loginRequest": {
          "customerType": 'ACCOUNT_NUMBER',
          "accountNumber": req[:phone_number],
          "pin": req[:pin]
        }
      }.to_json
      response = send_request(SMILES_LOGIN_PATH, params, request_headers)
      response
    end

    def get_smiles_member_info(phone_number)
      params = {
        "getMemberRequest": {
          "accountNumber": phone_number
        }
      }.to_json

      send_request(SMILES_MEMBER_INFO_PATH, params, request_headers)
    end

    def smiles_member_activity(req)
      params = {
        "memberActivityRequest": {
          "accountNumber": req[:account_number],
          "activityCode": req[:activity_code],
          "eventDate": Time.now.to_date,
          "partnerCode": ENV['SMILES_REQUESTED_SYSTEM'],
          "spendValue": req[:spend_value],
          "externalReferenceNumber": Time.now,
          "pointsValue": req[:points_value],
          "redemptionType": req[:redemption_type]
        }
      }.to_json

      response = send_request(SMILES_MEMBER_ACTIVITY_PATH, params, request_headers)
      response
    end

    def smiles_rollback(transaction_id)
      params = {
        "rollbackRequest": {
          "transactionRefId": transaction_id
        }
      }.to_json

      response = send_request(SMILES_ROLLBACK_PATH, params, request_headers)
      response
    end

    def smiles_enroll_member(req)
      params = {
        "enrollMemberRequest": {
          "enrollmentDetails": {
            "accountNumber": req[:phone_number],
            "deviceId": req[:device_id],
            "memberPersonalDetails": {
              "language": 'English',
              "email": req[:email]
            }
          }
        }
      }.to_json

      send_request(SMILES_ENROLL_MEMBER_PATH, params, request_headers)
    end

    def smiles_activate_account(phone_number)
      params = {
        "activateAccountsRequest": {
          "accountNumbers": phone_number
        }
      }.to_json

      send_request(SMILES_ACTIVATE_ACCOUNT_PATH, params, request_headers)
    end

    #================================= Smiles Login call for sdk ======================#

    def sdk_smiles_login(loyalty_id)
      params = {
        "loginRequest": {
          "loyaltyId": loyalty_id,
          "channelId": ENV['SMILES_REQUESTED_SYSTEM']
        }
      }.to_json

      send_request(SMILES_LOGIN_PATH, params, request_headers)
    end


    #================================= Smiles Member Info call for sdk ======================#

    def get_sdk_member_info(loyalty_id)
      params = {
          "loyaltyId": loyalty_id
      }.to_json

      send_request(SMILES_SDK_INFO_PATH, params, request_headers)
    end

    #================================ Send Push Notification =================================#

    def cns_loyalty(shopper, params, notification_id, order: nil)
      # language = order.present? ? order.language : shopper.language
      language = if order.present?
                   (order.device_type == shopper.device_type && order.platform_type == shopper.platform_type) ? shopper.language : order.language
                 else
                   shopper.language
                 end
      req = {
        "PushNotificationRequest": {
          "requestHeader": {
            "channel": "ELGROCER",
            "subChannel": "ELGROCER",
            "systemName": "ELGROCER",
            "hostId": "http://au461.etisalat.corp.ae:7080",
            "requestDate": Time.now
          },
          "requestData": {
            "accountNumber": shopper.phone_number,
            "notificationId": notification_id,
            "notificationCode": "00",
            "interactionReason": "Notification",
            "notificationLanguage": language,
            "orderReferenceNumber": order&.id,
            "origionTransactionId": order&.id,
            "dynamicParameters":  params.stringify_keys.map { |key, value| {'key' => key, 'value' => value} }.push({
                                                                                                                     "name": "PUSH",
                                                                                                                     "value": "SMILES_APP"
                                                                                                                   }),
            "additionalInfo": params.stringify_keys.map { |key, value| {'key' => key, 'value' => value} }.push({
                                                                                                                 "name": "PUSH",
                                                                                                                 "value": "SMILES_APP"
                                                                                                               }),
          }
        }
      }.to_json

      send_request(SMILES_PUSHNOTIFICATION_PATH, req, request_headers_sdk)
    end

    #
    # def send_request(url, params, headers)
    #   Excon.post(url,:proxy => ENV["PROXY_URL"], :body => params, :headers => headers)
    # end
    #
    # def faraday_send_request(url, params, headers)
    #   conn = Faraday.new(
    #     url: url,
    #     headers: headers,
    #     proxy: ENV["PROXY_URL"]
    #   )
    #   conn.post(url) do |req|
    #     req.body = params
    #   end
    # end
    def send_request(url, params, headers)
      conn = Faraday.new(
        url: url,
        headers: headers,
        proxy: ENV['PROXY_URL']
      ) do |faraday|
        faraday.adapter :httpclient
      end
      response = conn.post(url) do |req|
        req.body = params
      end
      send_to_kafka(url, params, response)
      response
    end

    def send_to_kafka(key, request, response)
      RequestResponseStreamJob.perform_later(topic: SystemConfiguration.get_key_value('smiles-non-transactional-apis'),
                                             key: key, event: 'Smiles API Call', request: request, response: response.body)
    end
  end
end
