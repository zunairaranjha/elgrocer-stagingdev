# frozen_string_literal: true

module API
  module V3
    module DeliverySlots
      class Index < Grape::API
        version 'v3', using: :path
        format :json

        resource :delivery_slots do
          desc "List of all retailers. Requires authentication.", entity: API::V1::DeliverySlots::Entities::IndexEntity
          params do
            requires :retailer_id, desc: 'Retailer ID', documentation: { example: 10 }
            requires :retailer_delivery_zone_id, type: Integer, desc: 'Retailer DeliveryZone ID of products', documentation: { example: 20 }
            optional :item_count, type: Integer, desc: 'Order items count', documentation: { example: 10 }
          end
          get '/all' do
            retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id, :is_active, :is_opened, :updated_at).find_by(slug: params[:retailer_id], is_active: true) : Retailer.select(:id, :is_active, :is_opened, :updated_at).find_by(id: params[:retailer_id], is_active: true)
            error!(CustomErrors.instance.retailer_not_found, 421) unless retailer
            rdz = RetailerDeliveryZone.find_by(id: params[:retailer_delivery_zone_id])
            error!(CustomErrors.instance.invalid_zone, 421) unless rdz
            skip_time = rdz.delivery_slot_skip_time
            day_add = 1 + (rdz.cutoff_time.to_i > 0 ? 1 : 0) + ((Time.now.seconds_since_midnight >= rdz.cutoff_time.to_i and rdz.cutoff_time.to_i > 0) ? 1 : 0)
            start_time = day_add > 1 ? 0 : Time.now.seconds_since_midnight
            delivery_slots = DeliverySlot.slots_for_two_weeks(retailer.id, params[:retailer_delivery_zone_id], skip_time, day_add, params[:item_count].to_i, (Time.now.seconds_since_midnight >= rdz.cutoff_time.to_i and rdz.cutoff_time.to_i > 0), start_time)
            add_day = rdz.cutoff_time.to_i > 0 ? true : false

            is_opened = retailer.currently_opened(params[:retailer_delivery_zone_id])
            if !rdz.schedule? && is_opened
              deliverySlot = DeliverySlot.new(id: 0, day: Time.now.wday + 1, start: 28800, end: 79200, retailer_delivery_zone_id: params[:retailer_delivery_zone_id], products_limit: 0)
              delivery_slots = delivery_slots.to_a.insert(0, deliverySlot)
            end
            retailer_opened = {}
            retailer_opened[:retailer] = { id: retailer.id, is_opened: is_opened, add_day: add_day }

            present retailer_opened
            present delivery_slots, with: API::V1::DeliverySlots::Entities::IndexEntity, from_ios: request.headers['User-Agent'].include?("ElGrocerShopper")
          end
        end
      end
    end
  end
end