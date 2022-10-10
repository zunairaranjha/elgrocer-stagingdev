# frozen_string_literal: true

module API
  module V1
    module DeliverySlots
      class ClickAndCollect < Grape::API
        version 'v1', using: :path
        format :json

        resource :delivery_slots do
          desc 'Delivery Slots'
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer ID', documentation: { example: 3 }
            requires :for_checkout, type: Boolean, desc: 'Slots for checkout', documentation: { example: true }
            optional :item_count, type: Integer, desc: 'Order items count', documentation: { example: 3 }
          end

          get '/click_and_collect' do
            retailer = Retailer.find_by(id: params[:retailer_id])
            cc_service = retailer.click_and_collect_service
            skip_time = cc_service.delivery_slot_skip_time
            day_add = 1 + (cc_service.cutoff_time.to_i > 0 ? 1 : 0) + ((Time.now.seconds_since_midnight >= cc_service.cutoff_time.to_i and cc_service.cutoff_time.to_i > 0) ? 1 : 0)
            start_time = day_add > 1 ? 0 : Time.now.seconds_since_midnight
            is_opened = retailer.is_opened
            delivery_slots = []
            if !cc_service.schedule? and is_opened
              delivery_slots.push(DeliverySlot.new(id: 0, day: Time.now.wday + 1, start: 28800, end: 79200, products_limit: 0))
            end

            if cc_service.schedule? or (cc_service.instant_and_schedule? and params[:for_checkout])
              delivery_slots = delivery_slots.push(DeliverySlot.cnc_slots(retailer.id, skip_time, day_add, params[:item_count].to_i, (Time.now.seconds_since_midnight >= retailer.cutoff_time.to_i and retailer.cutoff_time.to_i > 0), start_time, params[:for_checkout])).flatten
            end
            add_day = retailer.cutoff_time.to_i > 0 ? true : false

            retailer_opened = {}
            retailer_opened[:retailer] = { id: retailer.id, is_opened: is_opened, add_day: add_day }

            present retailer_opened
            present delivery_slots, with: API::V1::DeliverySlots::Entities::IndexEntity, from_ios: request.headers['User-Agent'].include?('ElGrocerShopper')
          end
        end
      end
    end
  end
end
