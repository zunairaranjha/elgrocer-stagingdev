# frozen_string_literal: true

module API
  module V1
    module Configurations
      class EmployeeConfiguration < Grape::API
        version 'v1', using: :path
        format :json

        resource :configurations do
          desc 'This API will be used in picker for configurations'

          get '/employee' do
            {
              algolia_app_id: ENV["ALGOLIA_APP_ID"],
              algolia_api_key: ENV["ALGOLIA_ADMIN_API_KEY"],
              shopper_detail_reasons: SystemConfiguration.find_by_key('shopper_detail_reasons').value.to_s.split('-')
            }
          end
        end
      end
    end
  end
end
