# frozen_string_literal: true

module API
  module V2
    module DeliverySlots
      class Root < Grape::API
        version 'v2', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V2::DeliverySlots::Index
        mount API::V2::DeliverySlots::Delivery
        mount API::V2::DeliverySlots::ClickAndCollect
      end
    end
  end
end
