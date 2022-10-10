# frozen_string_literal: true

module API
  module V2
    module Retailers
      class Root < Grape::API
        version 'v2', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V2::Retailers::ShowProducts
        mount API::V2::Retailers::Index
        mount API::V2::Retailers::IsCovered
        mount API::V2::Retailers::Show
        mount API::V2::Retailers::CncRetailers
        mount API::V2::Retailers::DeliveryRetailers
        mount API::V2::Retailers::PaymentMethods
      end
    end
  end
end
