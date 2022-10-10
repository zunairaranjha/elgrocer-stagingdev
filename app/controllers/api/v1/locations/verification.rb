# frozen_string_literal: true

module API
  module V1
    module Locations
      class Verification < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :locations do
          desc 'Verificate location', entity: API::V1::Locations::Entities::ShowEntity
          params do
            requires :location_id, type: Integer, desc: 'Location id', documentation: { example: 2 }
          end
      
          post '/verification' do
            Location.unscoped.find_by_id(params[:location_id]).primary_id
          end
        end
      end      
    end
  end
end