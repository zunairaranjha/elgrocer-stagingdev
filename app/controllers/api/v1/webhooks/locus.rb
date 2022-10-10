# frozen_string_literal: true

module API
  module V1
    module Webhooks
      class Locus < Grape::API
        version 'v1', using: :path
        format :json

        resource :webhooks do
          params do
          end

          post '/locus' do
            order = Order.find_by(id: params[:task][:taskId])
            task = params[:task]
            pick = task[:taskGraph][:visits][0]
            drop = task[:taskGraph][:visits][1]
            # task_status = "%s %s%s/%s%s" % [task[:status][:status], pick[:id], pick[:visitStatus][:status], drop[:id], drop[:visitStatus][:status]]
            task_status = '%s %s/%s' % [task[:status][:status], pick[:visitStatus][:status], drop[:visitStatus][:status]]
            event = Event.find_or_create_by(name: "Locus #{task_status}")
            Analytic.create(owner: order || event, event_id: event.id, detail: params)
            return unless order && task[:assignedUser].present?

            # return unless task[:assignedUser].blank?
            driver_name = task[:assignedUser][:userId]
            # Analytic.add_activity("Locus #{params[:task][:status][:status]}", order, params.to_json)
            # Actual status. ACCEPTED - delivery person has accepted the task. STARTED - delivery person is moving towards the location. ARRIVED - delivery person has reached the location, and just waiting there. TRANSACTING - delivery person is at the location, and the transaction is in progress. COMPLETED - delivery person has completed the transaction at the location.
            # Allowed Values: RECEIVED, WAITING, ACCEPTED, STARTED, ARRIVED, TRANSACTING, COMPLETED, CANCELLED
            if pick[:visitStatus][:status].to_s.eql?('ARRIVED')
              employee = order.active_employee
              return unless employee

              employee.driver_at_pickup_notify(driver_name: driver_name)
            elsif pick[:visitStatus][:status].to_s.eql?('ACCEPTED')
              card_detail = order.card_detail.to_h.merge({'pick_eta' => pick['eta']['ARRIVED']['currentEta']['arrivalTime']}) rescue order.card_detail
              card_detail = card_detail.merge({'drop_eta' => drop['eta']['ARRIVED']['currentEta']['arrivalTime']}) rescue card_detail
              card_detail = card_detail.merge({ 'pick_tracking_url' => pick['trackLink'] }) rescue card_detail
              card_detail = card_detail.merge({ 'tracking_url' => drop['trackLink'] }) rescue card_detail
              order.update!(delivery_channel_id: delivery_driver(driver_name).id, card_detail: card_detail)
            elsif drop[:visitStatus][:status].to_s.eql?('STARTED')
              if order.status_id == 11
                order.update!(status_id: 2, delivery_channel_id: delivery_driver(driver_name).id)
              else
                card_detail = order.card_detail.to_h.merge({'drop_eta' => drop['eta']['ARRIVED']['currentEta']['arrivalTime']}) rescue order.card_detail
                order.update!(delivery_channel_id: delivery_driver(driver_name).id, card_detail: card_detail)
              end
            elsif drop[:visitStatus][:status].to_s.eql?('ARRIVED')
              order.shopper.driver_at_doorstep_notify(order: order, retailer_name: order.retailer_company_name, driver_name: driver_name)
            elsif task[:status][:status].to_s.eql?('COMPLETED') && [2, 11].include?(order.status_id)
              # TODO: Need to change this to all retailers while we are going live for driver for all stores
              # unless [16, 1020, 1021].include?(order.retailer_id) && PartnerIntegration.where(integration_type: 'locus_post_order').where(retailer_id: order.retailer_id, branch_code: [order.retailer_delivery_zone_id, nil, '']).present?
              order.update!(status_id: 5) unless DRIVER_PILOT_RETAILER_IDS.include?(order.retailer_id)
              # end
            end
            true
          end

          post '/locus_order_callback' do
            order = Order.find_by(id: params[:order][:id])
            task = params[:order]
            # pick = task[:taskGraph][:visits][0]
            # drop = task[:taskGraph][:visits][1]
            # task_status = "%s %s%s/%s%s" % [task[:status][:status], pick[:id], pick[:visitStatus][:status], drop[:id], drop[:visitStatus][:status]]
            task_status = '%s %s' % [task[:orderStatus], task[:orderSubStatus]]
            event = Event.find_or_create_by(name: "Locus #{task_status}")
            Analytic.create(owner: order || event, event_id: event.id, detail: params)
            return unless order && task[:tourDetail] && task[:tourDetail][:riderId]

            # return unless task[:assignedUser].blank?
            driver_name = task[:tourDetail][:riderId]
            # Analytic.add_activity("Locus #{params[:task][:status][:status]}", order, params.to_json)
            # Actual status. ACCEPTED - delivery person has accepted the task. STARTED - delivery person is moving towards the location. ARRIVED - delivery person has reached the location, and just waiting there. TRANSACTING - delivery person is at the location, and the transaction is in progress. COMPLETED - delivery person has completed the transaction at the location.
            # Allowed Values: RECEIVED, WAITING, ACCEPTED, STARTED, ARRIVED, TRANSACTING, COMPLETED, CANCELLED
            if task[:orderSubStatus].to_s.eql?('PICKUP_ONGOING')
              employee = order.active_employee
              return unless employee

              employee.driver_at_pickup_notify(driver_name: driver_name)
            elsif task[:orderStatus].to_s.eql?('PLANNED')
              card_detail = order.card_detail.to_h.merge({'pick_eta' => task['currentEta']}) rescue order.card_detail
              card_detail = card_detail.merge({'drop_eta' => task['currentEta']}) rescue card_detail
              card_detail = card_detail.merge({ 'pick_tracking_url' => task['trackingInfo']['link']}) rescue card_detail
              card_detail = card_detail.merge({ 'tracking_url' => task['trackingInfo']['link']}) rescue card_detail
              order.update!(delivery_channel_id: delivery_driver(driver_name).id, card_detail: card_detail)
            elsif task[:orderSubStatus].to_s.eql?('DROP_ENROUTE')
              if order.status_id == 11
                order.update!(status_id: 2, delivery_channel_id: delivery_driver(driver_name).id)
              else
                card_detail = order.card_detail.to_h.merge({'drop_eta' => task['currentEta']}) rescue order.card_detail
                order.update!(delivery_channel_id: delivery_driver(driver_name).id, card_detail: card_detail)
              end
            elsif task[:orderSubStatus].to_s.eql?('DROP_ONGOING')
              order.shopper.driver_at_doorstep_notify(order: order, retailer_name: order.retailer_company_name, driver_name: driver_name)
            elsif task[:orderStatus].to_s.eql?('COMPLETED') && [2, 11].include?(order.status_id)
              # TODO: Need to change this to all retailers while we are going live for driver for all stores
              order.update!(status_id: 5) unless DRIVER_PILOT_RETAILER_IDS.include?(order.retailer_id)
            end
            send_data(params, order) rescue ''
            true
          end

          post '/locus_tour_callback' do
            # tour_status = '%s' % [params[:tourUpdateEventType]]
            # event = Event.find_or_create_by(name: "Locus Tour #{tour_status}")
            # Analytic.create(owner: event, event_id: event.id, detail: params)
            Analytic.add_activity("Locus Tour #{params[:tourUpdateEventType]}", delivery_driver(params[:tourDetail][:riderId]), params)
          end
        end

        helpers do
          def delivery_driver(driver_name)
            delivery_driver = DeliveryChannel.find_by("name ilike '#{driver_name.downcase}'")
            delivery_driver ||= DeliveryChannel.create(name: driver_name)
            delivery_driver
          end

          def send_data(params, order)
            urls = SystemConfiguration.get_key_value('locus_webhook_urls')&.split(',')
            urls.each do |url|
              res = Faraday.post(url, params) rescue ''
              # Analytic.add_activity("OrderIQ Forward Data", order, {url: url, res: res.body})
            end
          end
        end
      end
    end
  end
end
