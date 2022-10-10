# frozen_string_literal: true

module API
  module V1
    module OrderFeedbacks
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :order_feedbacks do
          desc 'Create Order feedback' # , entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: 'ID of the order', documentation: { example: 16 }
            optional :delivery, type: Integer, desc: 'How was your delivery? 1-5 stars', documentation: { example: 4 }
            optional :speed, type: Integer, desc: 'When did your delivery arrive? 1)Early. 2)On Time. 3)Late. 4)Still Waiting.', documentation: { example: 4 }
            optional :accuracy, type: Integer, desc: 'Are you satisfied with the quality of the items our picker selected for you?1)Unsatisfied. 2)Somewhat unsatisfied. 3)Somewhat satisfied. 4)Satisfied.', documentation: { example: 4 }
            optional :price, type: Integer, desc: 'How would you rate the overall cost of grocery delivery? 1)Cheaper. 2)About the same. 3)More expensive.', documentation: { example: 4 }
            optional :comments, type: String, desc: 'feedback comments', documentation: { example: 'ice cream melted etc' }
          end

          post do
            order = Order.find_by(id: params[:order_id])
            # duration_str = Setting.first.feedback_duration || "120-2880"
            duration_str = Setting.select(:id, :feedback_duration).first.feedback_duration || '120-2880'
            duration_from = duration_str.split('-').first.to_f
            duration_to = duration_str.split('-').last.to_f

            if order && [2, 3, 5].include?(order.status_id) && (duration_from..duration_to).include?((Time.now - (order.processed_at || order.created_at)) / 1.minute)
              order_feedback = OrderFeedback.find_or_initialize_by(order_id: order.id)
              order_feedback.delivery = params[:delivery] if params[:delivery].to_i.positive?
              order_feedback.speed = params[:speed] if params[:speed].to_i.positive?
              order_feedback.accuracy = params[:accuracy] if params[:accuracy].to_i.positive?
              order_feedback.price = params[:price] if params[:price].to_i.positive?
              order_feedback.comments = params[:comments] unless params[:comments].blank?
              order_feedback.date_time_offset = request.headers['Datetimeoffset']
              order_feedback.save
              order_feedback
            else
              error!({ error_code: 403, error_key: 0, error_message: 'Time expired or invalid order' }, 403)
            end
          end
        end
      end
    end
  end
end
