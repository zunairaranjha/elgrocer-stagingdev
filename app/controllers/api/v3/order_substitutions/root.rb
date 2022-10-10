# frozen_string_literal: true

module API
  module V3
    module OrderSubstitutions
      class Root < Grape::API
        version 'v3', using: :path, vendor: 'api'
        format :json

        rescue_from :all, backtrace: true

        mount API::V3::OrderSubstitutions::Create
        mount API::V3::OrderSubstitutions::Update

      end
    end
  end
end