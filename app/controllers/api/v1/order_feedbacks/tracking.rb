# frozen_string_literal: true

module API
  module V1
    module OrderFeedbacks
      class Tracking < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :order_feedbacks do
          desc 'lists pending orders of a shopper'
          params do
            optional :retailer_id, type: Integer, desc: 'Retailer ID'
          end

          get '/tracking' do
            target_user = current_shopper || current_retailer
            # duration_str = Setting.first.feedback_duration || "120-2880"
            duration_str = Setting.select(:id, :feedback_duration).first.feedback_duration || '120-2880'
            duration_from = duration_str.split('-').first.to_f
            duration_to = duration_str.split('-').last.to_f

            orders = target_user.orders.where('status_id in (2,3,5)')
            orders = orders.where("extract('epoch' from now() - processed_at)/ 60 between ? and ?", duration_from, duration_to)
            orders = orders.where(feedback_status: 'feedback_pending')
            orders = orders.where(retailer_id: params[:retailer_id]) unless params[:retailer_id].blank?
            orders = orders.order('updated_at DESC')
            if request.headers['Datetimeoffset'].present?
              API::V1::OrderFeedbacks::Entities::ListEntity.represent orders, root: false
            else
              present orders, with: API::V1::OrderFeedbacks::Entities::ShowEntity
            end
          end
        end
      end
    end
  end
end
