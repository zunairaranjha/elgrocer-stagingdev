# frozen_string_literal: true

module API
  module V2
    module Favourites
      class Root < Grape::API
        include TokenAuthenticable
        version 'v2', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V2::Favourites::IndexRetailers
      
      end
    end
  end
end