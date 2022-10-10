# frozen_string_literal: true

module API
  module V1
    module Webhooks
      class Getswift < Grape::API
        version 'v1', using: :path
        format :json

        resource :webhooks do
          params do
          end

          post '/getswift' do
            order = Order.find_by(id: params[:Data][:Job][:Reference])
            event = Event.find_or_create_by(:name => "GetSwift #{params[:EventName]}")
            Analytic.create(:owner => order || event, :event_id => event.id, detail: params)
            return unless order
            driver_name = params[:Data][:Driver][:DriverName]
            # Analytic.add_activity("GetSwift #{params[:EventName]}", order, params.to_json)
            if params[:EventName].to_s.eql?("job/driveratpickup")
              employee = order.active_employee
              return unless employee
              employee.driver_at_pickup_notify(driver_name: driver_name)
            elsif params[:EventName].to_s.eql?("job/onway") and order.status_id == 11
              order.update!(status_id: 2, delivery_channel_id: delivery_driver(driver_name).id)
            elsif params[:EventName].to_s.eql?("job/driveratdropoff")
              order.shopper.driver_at_doorstep_notify(order: order, retailer_name: order.retailer_company_name, driver_name: driver_name)
            elsif params[:EventName].to_s.eql?("job/finished") and [2, 11].include? order.status_id
              order.update!(status_id: 5)
            else

            end
            true
          end
        end

        helpers do
          def delivery_driver(driver_name)
            delivery_driver = DeliveryChannel.find_by("name ilike '#{driver_name.downcase}'")
            delivery_driver = DeliveryChannel.create(name: driver_name) unless delivery_driver
            delivery_driver
          end
        end
      end
    end
  end
end
