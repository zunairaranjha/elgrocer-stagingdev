# frozen_string_literal: true

module API
  module V2
    module ShopperAddresses
      class Root < Grape::API
        version 'v2', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V2::ShopperAddresses::Create
        mount API::V2::ShopperAddresses::Update
      end      
    end
  end
end