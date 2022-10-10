# frozen_string_literal: true

module API
  module V1
    module Configurations
      class GetConfiguration < Grape::API
        # include TokenAuthenticable
        use ActionDispatch::RemoteIp
        version 'v1', using: :path
        format :json

        resource :configurations do
          desc 'Allows creation of an order substitutions'
          params do
          end

          get do
            {
              payfort_merchant_identifier: ENV['MERCHANT_IDENTIFIER'],
              payfort_access_code: ENV['PAYFORT_ACCESS_CODE'],
              payfort_sha_request_phrase: ENV['SHA_REQUEST_PHRASE'],
              payfort_paymentservices_url: ENV['PAYFORT_URL'],
              payfort_checkout_url: ENV['PAYFORT_CHECKOUT_URL'],
              #client_ip: env['action_dispatch.remote_ip'].to_s,
              client_ip: headers['X-Forwarded-For'].to_s.split(',').first.to_s,
              extra_amount: ENV['EXTRA_AMOUNT'],
              pg_18: I18n.t('shopper_agreements.pg_18'),
              applepay_switch: ActiveModel::Type::Boolean.new.cast(Redis.current.get('applepay_switch') || SystemConfiguration.find_by(key: 'applepay_switch')&.value),
              storyly_instance: String(Redis.current.get('storyly_instance') || SystemConfiguration.find_by(key: 'storyly_instance')&.value),
              sale_tag: String(Redis.current.get('sale_tag_url') || SystemConfiguration.find_by_key('sale_tag_url')&.value),
              fetch_catalog_from_algolia: ActiveModel::Type::Boolean.new.cast(SystemConfiguration.get_key_value('fetch_catalog_from_algolia')),
              order_total_steps: 6,
              smile_data: Partner.find_by_name('smile_data').smile_data,
              order_statuses: [
                {
                  key: '-1.1.0',
                  en: I18n.t('order_status.id_-1_1_0', locale: :en),
                  ar: I18n.t('order_status.id_-1_1_0', locale: :ar),
                  step_number: 0
                },
                {
                  key: '-1.1.1',
                  en: I18n.t('order_status.id_-1_1_1', locale: :en),
                  ar: I18n.t('order_status.id_-1_1_1', locale: :ar),
                  step_number: 0
                },
                {
                  key: '-1.2.0',
                  en: I18n.t('order_status.id_-1_2_0', locale: :en),
                  ar: I18n.t('order_status.id_-1_2_0', locale: :ar),
                  step_number: 0
                },
                {
                  key: '-1.2.1',
                  en: I18n.t('order_status.id_-1_2_1', locale: :en),
                  ar: I18n.t('order_status.id_-1_2_1', locale: :ar),
                  step_number: 0
                },
                {
                  key: '0.1.0',
                  en: I18n.t('order_status.id_0_1_0', locale: :en),
                  ar: I18n.t('order_status.id_0_1_0', locale: :ar),
                  step_number: 1
                },
                {
                  key: '0.2.0',
                  en: I18n.t('order_status.id_0_2_0', locale: :en),
                  ar: I18n.t('order_status.id_0_2_0', locale: :ar),
                  step_number: 1
                },
                {
                  key: '0.1.1',
                  en: I18n.t('order_status.id_0_1_1', locale: :en),
                  ar: I18n.t('order_status.id_0_1_1', locale: :ar),
                  step_number: 1
                },
                {
                  key: '0.2.1',
                  en: I18n.t('order_status.id_0_2_1', locale: :en),
                  ar: I18n.t('order_status.id_0_2_1', locale: :ar),
                  step_number: 1
                },
                {
                  key: '1.1.0',
                  en: I18n.t('order_status.id_1_1_0', locale: :en),
                  ar: I18n.t('order_status.id_1_1_0', locale: :ar),
                  step_number: 2
                },
                {
                  key: '1.1.1',
                  en: I18n.t('order_status.id_1_1_1', locale: :en),
                  ar: I18n.t('order_status.id_1_1_1', locale: :ar),
                  step_number: 2
                },
                {
                  key: '1.2.0',
                  en: I18n.t('order_status.id_1_2_0', locale: :en),
                  ar: I18n.t('order_status.id_1_2_0', locale: :ar),
                  step_number: 2
                },
                {
                  key: '1.2.1',
                  en: I18n.t('order_status.id_1_2_1', locale: :en),
                  ar: I18n.t('order_status.id_1_2_1', locale: :ar),
                  step_number: 2
                },
                {
                  key: '2.1.0',
                  en: I18n.t('order_status.id_2_1_0', locale: :en),
                  ar: I18n.t('order_status.id_2_1_0', locale: :ar),
                  step_number: 5
                },
                {
                  key: '2.1.1',
                  en: I18n.t('order_status.id_2_1_1', locale: :en),
                  ar: I18n.t('order_status.id_2_1_1', locale: :ar),
                  step_number: 5
                },
                {
                  key: '2.2.0',
                  en: I18n.t('order_status.id_2_2_0', locale: :en),
                  ar: I18n.t('order_status.id_2_2_0', locale: :ar),
                  step_number: 5
                },
                {
                  key: '2.2.1',
                  en: I18n.t('order_status.id_2_2_1', locale: :en),
                  ar: I18n.t('order_status.id_2_2_1', locale: :ar),
                  step_number: 5
                },
                {
                  key: '3.1.0',
                  en: I18n.t('order_status.id_3_1_0', locale: :en),
                  ar: I18n.t('order_status.id_3_1_0', locale: :ar),
                  step_number: 6
                },
                {
                  key: '3.1.1',
                  en: I18n.t('order_status.id_3_1_1', locale: :en),
                  ar: I18n.t('order_status.id_3_1_1', locale: :ar),
                  step_number: 6
                },
                {
                  key: '3.2.0',
                  en: I18n.t('order_status.id_3_2_0', locale: :en),
                  ar: I18n.t('order_status.id_3_2_0', locale: :ar),
                  step_number: 6
                },
                {
                  key: '3.2.1',
                  en: I18n.t('order_status.id_3_2_1', locale: :en),
                  ar: I18n.t('order_status.id_3_2_1', locale: :ar),
                  step_number: 6
                },
                {
                  key: '4.1.0',
                  en: I18n.t('order_status.id_4_1_0', locale: :en),
                  ar: I18n.t('order_status.id_4_1_0', locale: :ar),
                  step_number: 0
                },
                {
                  key: '4.1.1',
                  en: I18n.t('order_status.id_4_1_1', locale: :en),
                  ar: I18n.t('order_status.id_4_1_1', locale: :ar),
                  step_number: 0
                },
                {
                  key: '4.2.0',
                  en: I18n.t('order_status.id_4_2_0', locale: :en),
                  ar: I18n.t('order_status.id_4_2_0', locale: :ar),
                  step_number: 0
                },
                {
                  key: '4.2.1',
                  en: I18n.t('order_status.id_4_2_1', locale: :en),
                  ar: I18n.t('order_status.id_4_2_1', locale: :ar),
                  step_number: 0
                },
                {
                  key: '5.1.0',
                  en: I18n.t('order_status.id_5_1_0', locale: :en),
                  ar: I18n.t('order_status.id_5_1_0', locale: :ar),
                  step_number: 6
                },
                {
                  key: '5.1.1',
                  en: I18n.t('order_status.id_5_1_1', locale: :en),
                  ar: I18n.t('order_status.id_5_1_1', locale: :ar),
                  step_number: 6
                },
                {
                  key: '5.2.0',
                  en: I18n.t('order_status.id_5_2_0', locale: :en),
                  ar: I18n.t('order_status.id_5_2_0', locale: :ar),
                  step_number: 6
                },
                {
                  key: '5.2.1',
                  en: I18n.t('order_status.id_5_2_1', locale: :en),
                  ar: I18n.t('order_status.id_5_2_1', locale: :ar),
                  step_number: 6
                },
                {
                  key: '6.1.0',
                  en: I18n.t('order_status.id_6_1_0', locale: :en),
                  ar: I18n.t('order_status.id_6_1_0', locale: :ar),
                  step_number: 1
                },
                {
                  key: '6.1.1',
                  en: I18n.t('order_status.id_6_1_1', locale: :en),
                  ar: I18n.t('order_status.id_6_1_1', locale: :ar),
                  step_number: 1
                },
                {
                  key: '6.2.0',
                  en: I18n.t('order_status.id_6_2_0', locale: :en),
                  ar: I18n.t('order_status.id_6_2_0', locale: :ar),
                  step_number: 1
                },
                {
                  key: '6.2.1',
                  en: I18n.t('order_status.id_6_2_1', locale: :en),
                  ar: I18n.t('order_status.id_6_2_1', locale: :ar),
                  step_number: 1
                },
                {
                  key: '7.1.0',
                  en: I18n.t('order_status.id_7_1_0', locale: :en),
                  ar: I18n.t('order_status.id_7_1_0', locale: :ar),
                  step_number: 3
                },
                {
                  key: '7.1.1',
                  en: I18n.t('order_status.id_7_1_1', locale: :en),
                  ar: I18n.t('order_status.id_7_1_1', locale: :ar),
                  step_number: 3
                },
                {
                  key: '7.2.0',
                  en: I18n.t('order_status.id_7_2_0', locale: :en),
                  ar: I18n.t('order_status.id_7_2_0', locale: :ar),
                  step_number: 3
                },
                {
                  key: '7.2.1',
                  en: I18n.t('order_status.id_7_2_1', locale: :en),
                  ar: I18n.t('order_status.id_7_2_1', locale: :ar),
                  step_number: 3
                },
                {
                  key: '8.1.0',
                  en: I18n.t('order_status.id_8_1_0', locale: :en),
                  ar: I18n.t('order_status.id_8_1_0', locale: :ar),
                  step_number: 0
                },
                {
                  key: '8.1.1',
                  en: I18n.t('order_status.id_8_1_1', locale: :en),
                  ar: I18n.t('order_status.id_8_1_1', locale: :ar),
                  step_number: 0
                },
                {
                  key: '8.2.0',
                  en: I18n.t('order_status.id_8_2_0', locale: :en),
                  ar: I18n.t('order_status.id_8_2_0', locale: :ar),
                  step_number: 0
                },
                {
                  key: '8.2.1',
                  en: I18n.t('order_status.id_8_2_1', locale: :en),
                  ar: I18n.t('order_status.id_8_2_1', locale: :ar),
                  step_number: 0
                },
                {
                  key: '9.1.0',
                  en: I18n.t('order_status.id_9_1_0', locale: :en),
                  ar: I18n.t('order_status.id_9_1_0', locale: :ar),
                  step_number: 3
                },
                {
                  key: '9.1.1',
                  en: I18n.t('order_status.id_9_1_1', locale: :en),
                  ar: I18n.t('order_status.id_9_1_1', locale: :ar),
                  step_number: 3
                },
                {
                  key: '9.2.0',
                  en: I18n.t('order_status.id_9_2_0', locale: :en),
                  ar: I18n.t('order_status.id_9_2_0', locale: :ar),
                  step_number: 3
                },
                {
                  key: '9.2.1',
                  en: I18n.t('order_status.id_9_2_1', locale: :en),
                  ar: I18n.t('order_status.id_9_2_1', locale: :ar),
                  step_number: 3
                },
                {
                  key: '11.1.0',
                  en: I18n.t('order_status.id_11_1_0', locale: :en),
                  ar: I18n.t('order_status.id_11_1_0', locale: :ar),
                  step_number: 4
                },
                {
                  key: '11.1.1',
                  en: I18n.t('order_status.id_11_1_1', locale: :en),
                  ar: I18n.t('order_status.id_11_1_1', locale: :ar),
                  step_number: 4
                },
                {
                  key: '11.2.0',
                  en: I18n.t('order_status.id_11_2_0', locale: :en),
                  ar: I18n.t('order_status.id_11_2_0', locale: :ar),
                  step_number: 4
                },
                {
                  key: '11.2.1',
                  en: I18n.t('order_status.id_11_2_1', locale: :en),
                  ar: I18n.t('order_status.id_11_2_1', locale: :ar),
                  step_number: 4
                },
                {
                  key: '12.1.0',
                  en: I18n.t('order_status.id_12_1_0', locale: :en),
                  ar: I18n.t('order_status.id_12_1_0', locale: :ar),
                  step_number: 3
                },
                {
                  key: '12.1.1',
                  en: I18n.t('order_status.id_12_1_1', locale: :en),
                  ar: I18n.t('order_status.id_12_1_1', locale: :ar),
                  step_number: 3
                },
                {
                  key: '12.2.0',
                  en: I18n.t('order_status.id_12_2_0', locale: :en),
                  ar: I18n.t('order_status.id_12_2_0', locale: :ar),
                  step_number: 3
                },
                {
                  key: '12.2.1',
                  en: I18n.t('order_status.id_12_2_1', locale: :en),
                  ar: I18n.t('order_status.id_12_2_1', locale: :ar),
                  step_number: 3
                }
              ]
            }
          end
        end
      end
    end
  end
end