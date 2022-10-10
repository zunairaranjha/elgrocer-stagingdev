# frozen_string_literal: true

module API
  module V2
    module Orders
      class Root < Grape::API
        version 'v2', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V2::Orders::Tracking
        mount API::V2::Orders::Feedback
        mount API::V2::Orders::CheckOrderPositions
        mount API::V2::Orders::Index
        mount API::V2::Orders::Status
        mount API::V2::Orders::Search
        mount API::V2::Orders::Create
        mount API::V2::Orders::Show
        mount API::V2::Orders::Update
        mount API::V2::Orders::GetOrderPositions
        mount API::V2::Orders::OpenOrders
        mount API::V2::Orders::CreatePositions

      end
    end
  end
end
