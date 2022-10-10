module API
  module V1
    module Payments
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V1::Payments::PayfortResponse
        mount API::V1::Payments::AdyenResponse
        mount API::V1::Payments::Capture
        mount API::V1::Payments::ThresholdNotify
        mount API::V1::Payments::ThresholdApproval
        mount API::V1::Payments::AdyenCheckout

      end
    end
  end
end
