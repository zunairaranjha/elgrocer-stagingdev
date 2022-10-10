# frozen_string_literal: true

module API
  module V2
    class Base < Grape::API
      version ['v2', 'v1'], using: :path, vendor: 'api'
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

      mount API::V2::Retailers::Root
      mount API::V2::Categories::Root
      mount API::V2::Shoppers::Root
      mount API::V2::ShopperAddresses::Root
      mount API::V2::LocationWithoutShops::Root
      mount API::V2::RetailerReports::Root
      mount API::V2::Orders::Root
      mount API::V2::Analytics::Root
      mount API::V2::PromotionCodes::Root
      mount API::V2::Favourites::Root
      mount API::V2::DeliverySlots::Root
      mount API::V2::Recipes::Root
      mount API::V2::Chefs::Root
      mount API::V2::RecipeCategories::Root
      mount API::V2::Products::Root
      mount API::V2::OrderSubstitutions::Root
      mount API::V2::ShopperCartProducts::Root

    end
  end
end
