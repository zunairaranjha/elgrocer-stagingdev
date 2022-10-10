# frozen_string_literal: true

module API
  module V1
    module Versions
      class CheckVersion < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :versions do
          params do
            requires :client_version, type: String, desc: 'Client Version'
            requires :client_type, type: Integer, desc: '1 - IOS; 2 - Android retailer app'
          end
      
          post '/check_version' do
            check_version = ::Versions::CheckVersion.run(params)
            present check_version.result, with: API::V1::Versions::Entities::CheckVersionEntity
            # { action: 0 }
          end
        end
      end      
    end
  end
end