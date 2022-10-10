# frozen_string_literal: true

module API
  module V2
    module DeliverySlots
      class Index < Grape::API
        version 'v2', using: :path
        format :json
      
        resource :delivery_slots do
          desc "List of all retailers. Requires authentication.", entity: API::V1::DeliverySlots::Entities::IndexEntity
          params do
            requires :retailer_id, desc: 'Retailer ID', documentation: { example: 10 }
            requires :retailer_delivery_zone_id, type: Integer, desc: 'Retailer DeliveryZone ID of products', documentation: { example: 20 }
            optional :item_count, type: Integer, desc: 'Order items count', documentation: {example: 10}
          end
          get '/all' do
            retailer = params[:retailer_id][/\p{L}/] ? Retailer.find_by(slug: params[:retailer_id]) : Retailer.find_by(id: params[:retailer_id])
            skip_time = retailer.delivery_slot_skip_hours
            day_add = 1 + (retailer.cutoff_time.to_i > 0 ? 1 : 0) + ((Time.now.seconds_since_midnight >= retailer.cutoff_time.to_i and retailer.cutoff_time.to_i > 0) ? 1 : 0)
            start_time = day_add > 1 ? 0 : Time.now.seconds_since_midnight
            delivery_slots = DeliverySlot.get_slots(retailer.id, params[:retailer_delivery_zone_id], skip_time, day_add, params[:item_count].to_i, (Time.now.seconds_since_midnight >= retailer.cutoff_time.to_i and retailer.cutoff_time.to_i > 0), start_time)
            add_day = retailer.cutoff_time.to_i > 0 ? true : false
            if delivery_slots.length < 1
              add_day = true
              day_add += 1
              delivery_slots = DeliverySlot.get_slots(retailer.id, params[:retailer_delivery_zone_id], skip_time, day_add, params[:item_count].to_i, (Time.now.seconds_since_midnight >= retailer.cutoff_time.to_i and retailer.cutoff_time.to_i > 0), start_time)
            end
            # if delivery_slots.length < 1
            #   day_add += 1
            #   delivery_slots = DeliverySlot.get_slots(retailer.id, params[:retailer_delivery_zone_id], skip_time, day_add, params[:item_count].to_i, (Time.now.seconds_since_midnight >= retailer.cutoff_time.to_i and retailer.cutoff_time.to_i > 0), start_time)
            # end
            is_opened = retailer.currently_opened(params[:retailer_delivery_zone_id])
            if retailer.delivery_type_id != 1 && is_opened
              deliverySlot = DeliverySlot.new(id: 0, day: Time.now.wday + 1, start: 28800, end: 79200, retailer_delivery_zone_id: params[:retailer_delivery_zone_id], products_limit: 0)
              delivery_slots = delivery_slots.to_a.insert(0, deliverySlot)
            end
            retailer_opened = {}
            retailer_opened[:retailer] = {id: retailer.id, is_opened: is_opened, add_day: add_day }
      
            present retailer_opened
            present delivery_slots, with: API::V1::DeliverySlots::Entities::IndexEntity
          end
        end
      end
    end
  end
end