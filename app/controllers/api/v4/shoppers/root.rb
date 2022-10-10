
# frozen_string_literal: true

module API
  module V4
    module Shoppers
      class Root < Grape::API
        version 'v4', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V4::Shoppers::Register
      end
    end
  end
end