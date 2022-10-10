# frozen_string_literal: true

module API
  module V1
    module PromotionCodes
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V1::PromotionCodes::CheckAndRealize
        mount API::V1::PromotionCodes::Create
        mount API::V1::PromotionCodes::List
      end

    end
  end
end
