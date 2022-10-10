# frozen_string_literal: true

module API
  module V2
    module DeliverySlots
      class ClickAndCollect < Grape::API
        version 'v2', using: :path
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
            is_opened = retailer.is_opened
            delivery_slots = []
            if !cc_service.schedule? && is_opened
              time = Time.now
              delivery_slots << RetailerAvailableSlot.new(id: 0, day: time.wday + 1, start: time.seconds_since_midnight,
                                                          end: time.seconds_since_midnight + 3600,
                                                          week: (time + 1.day).strftime('%V'),
                                                          retailer_delivery_zone_id: params[:retailer_delivery_zone_id],
                                                          products_limit: 0)
            end

            if cc_service.schedule? || (cc_service.instant_and_schedule? && params[:for_checkout])
              delivery_slots << RetailerAvailableSlot.where(retailer_id: retailer.id, retailer_service_id: 2)
                                                     .where("total_limit = 0 OR ((total_products::numeric/(total_limit::numeric * 1.0)) <= 0.7) OR (total_limit + total_margin) >= (total_products + #{params[:item_count].to_i})")
                                                     .limit(36)
              delivery_slots = delivery_slots.flatten
            end

            retailer_opened = {}
            retailer_opened[:retailer] = { id: retailer.id, is_opened: is_opened }

            present retailer_opened
            present delivery_slots, with: API::V2::DeliverySlots::Entities::IndexEntity,
                                    from_ios: request.headers['User-Agent'].include?('ElGrocerShopper')
          end
        end
      end
    end
  end
end
