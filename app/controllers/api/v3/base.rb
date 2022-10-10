# frozen_string_literal: true

module API
  module V3
    class Base < Grape::API
      version ['v3', 'v2', 'v1'], using: :path, vendor: 'api'
      default_format :json

      before do
        I18n.locale = request.headers['Locale'] || params[:locale] || I18n.default_locale
      end

      module JSendSuccessFormatter
        def self.call object, env
          { status: 'success', data: object }.to_json
        end
      end

      module JSendErrorFormatter
        def self.call message, backtrace, options, env, original_exception
          if message.instance_of?(ActiveInteraction::Errors)
            { status: 'fail', messages: message }.to_json
          else
            { status: 'error', messages: message }.to_json
          end
        end
      end

      formatter :json, JSendSuccessFormatter
      error_formatter :json, JSendErrorFormatter

      mount API::V3::Retailers::Root
      mount API::V3::Categories::Root
      mount API::V3::Orders::Root
      mount API::V3::DeliverySlots::Root
      mount API::V3::PromotionCodes::Root
      mount API::V3::Shoppers::Root
      mount API::V3::OrderSubstitutions::Root

    end
  end
end