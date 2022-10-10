# frozen_string_literal: true

module API
  module V3
    module Orders
      class Root < Grape::API
        version 'v3', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V3::Orders::Tracking
        mount API::V3::Orders::Create
        mount API::V3::Orders::Update
        mount API::V3::Orders::Index
        mount API::V3::Orders::Show
        mount API::V3::Orders::Search
        mount API::V3::Orders::CreateOrder
        mount API::V3::Orders::UpdateOrder

      end
    end
  end
end
