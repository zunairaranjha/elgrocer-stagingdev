# frozen_string_literal: true

SMILES_BASE_URL = 'https://apihub.etisalat.ae:9443/etisalat/smiles/'
SMILES_BASE_URL_SDK = 'https://apihub.etisalat.ae:9443/etisalat/middleware/'
SMILES_AUTH_URL = "#{SMILES_BASE_URL}confidential/oauth2/token"
SMILES_AUTH_URL_SDK = "#{SMILES_BASE_URL_SDK}confidential/oauth2/token"
SMILES_ACCOUNT_PIN_PATH = "#{SMILES_BASE_URL}v2.0.0/accountpin"
SMILES_LOGIN_PATH = "#{SMILES_BASE_URL}v2.0.0/login"
SMILES_MEMBER_INFO_PATH = "#{SMILES_BASE_URL}v2.0.0/getMember"
SMILES_MEMBER_ACTIVITY_PATH = "#{SMILES_BASE_URL}v2.0.0/memberactivity"
SMILES_ROLLBACK_PATH = "#{SMILES_BASE_URL}v2.0.0/rollback"
SMILES_ENROLL_MEMBER_PATH = "#{SMILES_BASE_URL}v2.0.0/enrollmember"
SMILES_ACTIVATE_ACCOUNT_PATH = "#{SMILES_BASE_URL}activateAccounts/V1.0"
DRIVER_PILOT_RETAILER_IDS = ENV['DRIVE_APP_TEST_RETAILERS'].scan(/\d+/).map(&:to_i).freeze
SMILES_PUSHNOTIFICATION_PATH = "#{SMILES_BASE_URL_SDK}service/v1.0.0/cnsPushNotification"
SMILES_SDK_LOGIN_PATH = "#{SMILES_BASE_URL}v2.0.0/login"
SMILES_SDK_INFO_PATH = "#{SMILES_BASE_URL}v2.0.0/getMember"
ANALYTICS_START_DATE = '2022-01-01'
SUCCESSFUL_HTTP_STATUS = [200, 201, 202, 203, 204, 205, 206].freeze