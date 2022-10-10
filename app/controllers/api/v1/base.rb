module API
  module V1
    class Base < Grape::API
      version 'v1', using: :path, vendor: 'api'
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

      mount API::V1::Retailers::Root
      mount API::V1::RetailerReviews::Root
      mount API::V1::Favourites::Root
      mount API::V1::Sessions::Root
      mount API::V1::Products::Root
      mount API::V1::Brands::Root
      mount API::V1::Countries::Root
      mount API::V1::Categories::Root
      mount API::V1::Shoppers::Root
      mount API::V1::ShopperAddresses::Root
      mount API::V1::Orders::Root
      mount API::V1::Cities::Root
      mount API::V1::Locations::Root
      mount API::V1::PromotionCodes::Root
      mount API::V1::ShopperCartProducts::Root
      mount API::V1::Versions::Root
      mount API::V1::DeliverySlots::Root
      mount API::V1::OrderSubstitutions::Root
      mount API::V1::ProductSuggestions::Root
      mount API::V1::OrderFeedbacks::Root
      mount API::V1::Banners::Root
      mount API::V1::Chefs::Root
      mount API::V1::Recipes::Root
      mount API::V1::RecipeCategories::Root
      mount API::V1::CookingSteps::Root
      mount API::V1::PartnerIntegrations::Root
      mount API::V1::CreditCards::Root
      mount API::V1::Payments::Root
      mount API::V1::Configurations::Root
      mount API::V1::Screens::Root
      mount API::V1::Employees::Root
      mount API::V1::ShopperAgreements::Root
      mount API::V1::AddressTags::Root
      mount API::V1::Webhooks::Root
      mount API::V1::CollectorDetails::Root
      mount API::V1::PickupLocations::Root
      mount API::V1::VehicleDetails::Root
      mount API::V1::OrderCollectionDetails::Root
      mount API::V1::Campaigns::Root
      mount API::V1::ShopperRecipes::Root
      mount API::V1::Smiles::Root
      mount API::V1::ProductProposals::Root
    end
  end
end