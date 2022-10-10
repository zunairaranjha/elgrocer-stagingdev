# frozen_string_literal: true

module API
  module V1
    module Retailers
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V1::Retailers::ShowProfile
        mount API::V1::Retailers::ShowProducts
        mount API::V1::Retailers::UpdateProfile
        mount API::V1::Retailers::UpdatePhoto
        mount API::V1::Retailers::ElasticSearch
        mount API::V1::Retailers::Index
        mount API::V1::Retailers::UpdateIsOpened
        mount API::V1::Retailers::ResetPasswordRequest
        mount API::V1::Retailers::CheckIfOnline
        mount API::V1::Retailers::TopSearches
        mount API::V1::Retailers::ShowRetailer
        mount API::V1::Retailers::IsCoveredForRetailer
        mount API::V1::Retailers::PaymentMethods
        mount API::V1::Retailers::ClickAndCollect
      end
    end
  end
end