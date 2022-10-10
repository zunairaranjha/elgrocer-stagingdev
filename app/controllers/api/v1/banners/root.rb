

module API
  module V1
    module Banners
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        rescue_from :all, backtrace: true
      
        mount API::V1::Banners::Index
        mount API::V1::Banners::Show
      
      end
    end
  end
end