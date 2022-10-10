module API
  module V1
    module DeliverySlots
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V1::DeliverySlots::Index
        mount API::V1::DeliverySlots::ClickAndCollect
      end
    end
  end
end