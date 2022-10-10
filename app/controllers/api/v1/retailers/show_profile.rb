# frozen_string_literal: true

module API
  module V1
    module Retailers
      class ShowProfile < Grape::API
        version 'v1', using: :path
        format :json

        resource :retailers do
          desc "Returns profile of a retailer.", entity: API::V1::Retailers::Entities::ShowProfileEntity
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer ID'
          end
          get do
            result = ::Retailers::ShowProfile.run(retailer_id: params[:retailer_id])
            if result.valid?
              present result.result, with: API::V1::Retailers::Entities::ShowProfileEntity
            else
              error!({ error_code: 403, error_message: "Retailer does not exist" }, 403)
            end
          end

        end
      end
    end
  end
end