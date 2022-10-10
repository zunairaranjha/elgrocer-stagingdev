# frozen_string_literal: true

module API
  module V2
    module Orders
      class CheckOrderPositions < Grape::API
        version 'v2', using: :path
        format :json
      
        resource :orders do
          desc "Checks avalability of products in shops in location", entity: API::V1::Orders::Entities::CheckEntity
          params do
            requires :longitude, type: Float, desc: "Shopper longitude"
            requires :latitude, type: Float, desc: "Shopper latitude"
            requires :products, type: Array, desc: "ID of desired product", documentation: { example: "5"}
          end
      
          post '/check' do
            interactor_result = ::Orders::CheckSchedulePositions.run(params)
            if interactor_result.valid?
              result = { retailers: interactor_result.result }
              present result, with: API::V1::Orders::Entities::CheckEntity
            else
              error!({ error_code: 422, error_message: interactor_result.errors }, 422)
            end
          end
        end
      end
    end
  end
end