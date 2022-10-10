# frozen_string_literal: true

module API
  module V2
    module Shoppers
      class Root < Grape::API
        version 'v2', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V2::Shoppers::CheckShopper
        mount API::V2::Shoppers::Register
        mount API::V2::Shoppers::Wallet
        mount API::V2::Shoppers::DigitsVerify
        mount API::V2::Shoppers::CheckPhone
        mount API::V2::Shoppers::LocationData
      end
      
    end
  end
end