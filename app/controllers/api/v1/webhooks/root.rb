# frozen_string_literal: true

module API
  module V1
    module Webhooks
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V1::Webhooks::ShopperPushNotification
        mount API::V1::Webhooks::ShopperDetail
        mount API::V1::Webhooks::EmployeeDetail
        mount API::V1::Webhooks::EmployeeList
        mount API::V1::Webhooks::OrderDetail
        mount API::V1::Webhooks::EmployeeOrders
        mount API::V1::Webhooks::Getswift
        mount API::V1::Webhooks::Locus
      end
    end
  end
end
