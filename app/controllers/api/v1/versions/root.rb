# frozen_string_literal: true

module API
  module V1
    module Versions
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::Versions::CheckVersion
      end
    end
  end
end