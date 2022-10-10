# frozen_string_literal: true

module API
  module V2
    module Orders
      class Feedback < Grape::API
        include TokenAuthenticable
        version 'v2', using: :path
        format :json
      
        resource :orders do
          desc "lists pending orders of a shopper" #, entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: "ID of the order", documentation: { example: 16 }
            requires :is_on_time, type: Boolean, desc: 'Deliver on time?', documentation: { example: true }
            requires :is_accurate, type: Boolean, desc: 'Items Accurate?', documentation: { example: true }
            requires :is_price_same, type: Boolean, desc: 'Final Prices as in app?', documentation: { example: true }
            requires :feedback_comments, type: String, desc: 'Shopper feedback comments', documentation: { example: "ice cream melted etc" }
          end
      
          put '/feedback' do
            order = Order.find_by(id: params[:order_id])
      
            ::SlackNotificationJob.perform_later(order.id, 12)
            
            # if (order && order.status_id == 2)
              order.update_attributes(is_on_time: params[:is_on_time],is_accurate: params[:is_accurate],is_price_same: params[:is_price_same],feedback_comments: params[:feedback_comments])
            # else
            #   order.status
            # end
          end
        end
      end
    end
  end
end