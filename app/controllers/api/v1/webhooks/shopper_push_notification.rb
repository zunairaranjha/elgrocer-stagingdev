# frozen_string_literal: true

module API
  module V1
    module Webhooks
      class ShopperPushNotification < Grape::API
        version 'v1', using: :path
        format :json

        resource :webhooks do

          post '/shopper_push_notification' do
            params[:notification][:origin] = 'el-grocer-api'
            params[:devices]&.each do |device|
              _params = params[:notification]
              _params[:message_type] = 900
              if device[:type].eql?('ios')
                AppleNotifications.push(device[:identifier], _params, _params[:title])
              else
                _params[:push_type] = _params.delete(:message_type)
                GoogleMessaging.push(device[:identifier], _params, nil, nil, nil, false)
              end
            end
            { message: 'ok' }
          end
        end
      end
    end
  end
end 