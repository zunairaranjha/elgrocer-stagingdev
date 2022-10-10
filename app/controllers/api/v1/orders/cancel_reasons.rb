# frozen_string_literal: true

module API
  module V1
    module Orders
      class CancelReasons < Grape::API
        version 'v1', using: :path
        format :json
        resource :orders do
          desc 'lists all order cancellation reasons of a shopper '

          get '/cancel/reasons' do
            result = JSON(SystemConfiguration.find_by(key: 'order_cancel').value).to_a
            present result, with: API::V1::Orders::Entities::CancelReasonsEntity
          end
        end
      end
    end
  end
end
