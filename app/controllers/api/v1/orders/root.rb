# frozen_string_literal: true

module API
  module V1
    module Orders
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V1::Orders::Index
        mount API::V1::Orders::Recent
        mount API::V1::Orders::Search
        mount API::V1::Orders::Create
        mount API::V1::Orders::Status
        mount API::V1::Orders::Approve
        mount API::V1::Orders::DeleteRetailer
        mount API::V1::Orders::DeleteShopper
        mount API::V1::Orders::CheckOrderPositions
        mount API::V1::Orders::Convert
        mount API::V1::Orders::ChangeSlot
        mount API::V1::Orders::Tracking
        mount API::V1::Orders::OrdersCount
        mount API::V1::Orders::Available
        mount API::V1::Orders::SelectOrder
        mount API::V1::Orders::UnselectOrder
        mount API::V1::Orders::Update
        mount API::V1::Orders::GetOrderPositions
        mount API::V1::Orders::ChangePaymentType
        mount API::V1::Orders::CreatePositions
        mount API::V1::Orders::OnlinePaymentDetails
        mount API::V1::Orders::OpenOrders
        mount API::V1::Orders::CancelReasons
        mount API::V1::Orders::Preference
        mount API::V1::Orders::Show
      end
    end
  end
end
