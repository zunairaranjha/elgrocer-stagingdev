module API
  module V1
    module Screens
      class Root < Grape::API
        version 'v1', using: :path, vendor: 'api'
        format :json
      
        mount API::V1::Screens::Index
        mount API::V1::Screens::Show
        mount API::V1::Screens::ScreenProducts
      end      
    end
  end
end