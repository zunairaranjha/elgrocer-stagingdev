# frozen_string_literal: true

module API
  module V1
    module Shoppers
      class ShowProfile < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :shoppers do
          desc 'Returns profile of a current shopper.', entity: API::V1::Shoppers::Entities::ShowProfileEntity
          get '/show_profile' do
            result = ::Shoppers::ShowProfile.run(shopper_id: current_shopper.id)
            if result.valid?
              present result.result, with: API::V1::Shoppers::Entities::ShowProfileEntity
            else
              error!({ error_code: 403, error_message: 'You are not logged or shopper dont exist.' }, 403)
            end
          end
        end
      end
    end
  end
end