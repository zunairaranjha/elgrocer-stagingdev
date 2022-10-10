# frozen_string_literal: true

module API
  module V2
    module DeliverySlots
      class Delivery < Grape::API
        version 'v2', using: :path
        format :json

        resource :delivery_slots do
          desc 'List of all retailers. Requires authentication.', entity: API::V1::DeliverySlots::Entities::IndexEntity
          params do
            requires :retailer_id, desc: 'Retailer ID', documentation: { example: 10 }
            requires :retailer_delivery_zone_id, type: Integer, desc: 'Retailer DeliveryZone ID of products', documentation: { example: 20 }
            optional :item_count, type: Integer, desc: 'Order items count', documentation: { example: 10 }
          end
          get '/delivery' do
            retailer = if params[:retailer_id][/\p{L}/]
                         Retailer.select(:id, :is_active, :is_opened, :updated_at).find_by(slug: params[:retailer_id], is_active: true)
                       else
                         Retailer.select(:id, :is_active, :is_opened, :updated_at).find_by(id: params[:retailer_id], is_active: true)
                       end
            error!(CustomErrors.instance.retailer_not_found, 421) unless retailer
            rdz = RetailerDeliveryZone.find_by(id: params[:retailer_delivery_zone_id])
            error!(CustomErrors.instance.invalid_zone, 421) unless rdz
            delivery_slots = RetailerAvailableSlot.where(retailer_id: retailer.id, retailer_delivery_zone_id: rdz.id, retailer_service_id: 1)
                                                  .where("total_limit = 0 OR ((total_products::numeric/(total_limit::numeric * 1.0)) <= 0.7) OR (total_limit + total_margin) >= (total_products + #{params[:item_count].to_i})")
                                                  .limit(36)
            is_opened = retailer.currently_opened(params[:retailer_delivery_zone_id])
            if !rdz.schedule? && is_opened
              time = Time.now
              delivery_slot = RetailerAvailableSlot.new(id: 0, day: time.wday + 1, start: time.seconds_since_midnight,
                                                        end: time.seconds_since_midnight + 3600,
                                                        week: (time + 1.day).strftime('%V'),
                                                        retailer_delivery_zone_id: params[:retailer_delivery_zone_id],
                                                        products_limit: 0)
              delivery_slots = delivery_slots.to_a.insert(0, delivery_slot)
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

