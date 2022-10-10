# frozen_string_literal: true

module API
  module V2
    module Analytics
      class Create < Grape::API
        version 'v2', using: :path
        format :json

        resource :analytics do
          desc 'Add user activity logs'

          params do
            optional :shopper_id, type: Integer, desc: 'Shopper id, is existing shopper', documentation: { example: 20 }
            requires :event_id, type: Integer, desc: 'Event id'
            # optional :created_at, type: Datetime, desc: 'Created at datetime'
          end

          post do
            Analytic.create!({ shopper_id: params['shopper_id'], event_id: params['event_id'] })
          end
        end
      end
    end
  end
end
