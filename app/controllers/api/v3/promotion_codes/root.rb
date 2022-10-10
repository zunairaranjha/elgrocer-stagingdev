# frozen_string_literal: true

module API
  module V3
    module PromotionCodes
      class Root < Grape::API
        version 'V3', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V3::PromotionCodes::CheckAndRealize
        mount API::V3::PromotionCodes::CreateRealization
      end
    end
  end
end
