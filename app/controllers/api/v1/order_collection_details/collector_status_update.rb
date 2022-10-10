module API
  module V1
    module OrderCollectionDetails
      class CollectorStatusUpdate < Grape::API
        version 'v1', using: :path
        format :json

        resource :order_collection_details do
          desc 'Update Collector Status'
          params do
            requires :order_id, type: Integer, desc: 'Id of Order', documentation: { example: 3 }
            optional :collector_id, type: Integer, desc: 'Collector Id', documentation: { example: 3 }
            optional :shopper_id, type: Integer, desc: 'Shopper Id', documentation: { example: 3 }
            requires :collector_status, type: Integer, desc: 'Collector Status', documentation: { example: 1 }
          end

          put '/update' do
            order = Order.select(:id, :shopper_id, :retailer_id).find_by(id: params[:order_id], retailer_service_id: 2)
            unless order.present?
              error!(CustomErrors.instance.order_not_found, 421)
            end
            # if order.order_service == 1

            # end
            collection_detail = order.order_collection_detail
            # shopper = order.shopper
            # collector = order.collector_detail
            # unless (params[:shopper_id].present? and params[:shopper_id] == shopper.id) or (params[:collector_id].present? and params[:collector_id] == collector.id)
            #   error!(CustomErrors.instance.params_missing, 421)
            # end
            status = case params[:collector_status].to_i
                     when 1
                       'on_my_way'
                     when 2
                       'at_the_store'
                     else
                       'not_confirmed'
                     end
            event = {}
            event[status] = Time.now.to_s
            object = {
              collector_status: status.humanize,
              events: collection_detail.events.merge!(event),
              date_time_offset: request.headers['Datetimeoffset']
            }
            collection_detail.update!(object.compact)

            oa = order.order_allocations.where(is_active: true).first
            if oa
              emp = oa.employee
              case params[:collector_status].to_i
              when 1
                status = I18n.t('push_message.message_108', order_id: order.id)
                message_type = 108
              when 2
                status = I18n.t('push_message.message_112', order_id: order.id)
                message_type = 112
              end
              params = {
                'message': status,
                'status': status,
                'retailer_id': order.retailer_id,
                'order_id': order.id,
                'message_type': message_type
              }
              PushNotificationJob.perform_later(emp.registration_id, params, 0, true)
            end
            { message: 'ok' }
          end
        end
      end
    end
  end
end
