# frozen_string_literal: true

module API
  module V1
    module Shoppers
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V1::Shoppers::Register
        mount API::V1::Shoppers::UpdateInvoiceAddress
        mount API::V1::Shoppers::Update
        mount API::V1::Shoppers::ResetPasswordRequest
        mount API::V1::Shoppers::ShowProfile
        mount API::V1::Shoppers::GetShopperIp
        mount API::V1::Shoppers::Delete
        mount API::V1::Shoppers::DeletionReasons
        mount API::V1::Shoppers::DeleteShopper
      end
    end
  end
end
