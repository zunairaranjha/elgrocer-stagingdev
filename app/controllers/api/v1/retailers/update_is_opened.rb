# frozen_string_literal: true

module API
  module V1
    module Retailers
      class UpdateIsOpened < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :retailers do
          desc  "Update is_opened. Requires authentication.", entity: API::V1::Retailers::Entities::ShowProfileEntity
          params do
            requires :is_opened, type: Boolean, desc: "Describes if a shop is opened"
          end
          put '/update_is_opened' do
            retailer = current_retailer
      
            retailer.is_opened = params[:is_opened]
            retailer.source = 'app/api'
            #retailer.save
            present retailer, with: API::V1::Retailers::Entities::ShowProfileEntity
          end
        end
      end      
    end
  end
end