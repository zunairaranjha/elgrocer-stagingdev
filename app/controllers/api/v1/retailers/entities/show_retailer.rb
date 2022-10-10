module API
  module V1
    module Retailers
      module Entities
        class ShowRetailer < API::BaseEntity
          root 'retailers', 'retailer'

          def self.entity_name
            'show_retailer'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :company_name, documentation: { type: 'String', desc: 'Shop name' }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: "URL friendly name" }, format_with: :string
          expose :company_address, documentation: { type: 'String', desc: 'Shop address' }, format_with: :string
          expose :is_favourite, documentation: { type: "Boolean", desc: 'Determines if retailer is in favourites' }, format_with: :bool
          expose :average_rating, documentation: { type: 'Float', desc: 'Shop average rating' }, format_with: :float
          expose :photo_url, documentation: { type: 'String', desc: "An URL directing to a photo of the shop." }, format_with: :string
          expose :photo1_url, documentation: { type: 'String', desc: "An URL directing to a photo of the shop." }, format_with: :string
          # expose :locations, using: API::V1::Locations::Entities::ShowEntityWithMinBasket, documentation: {type: 'show_location', is_array: true }
          expose :min_basket_value, documentation: { type: 'Float', desc: 'Shop average rating' }, format_with: :float
          expose :is_opened, documentation: { type: 'Boolean', desc: 'Describes if retailer is opened' }, format_with: :bool
          expose :is_in_range, documentation: { type: 'Boolean', desc: 'Describes if favourite retailer is in range' }, format_with: :bool
          expose :available_payment_types, using: API::V1::Retailers::Entities::ShowPaymentTypeEntity, documentation: { type: 'show_payment_type', is_array: true }
          expose :delivery_type_id, documentation: { type: 'Integer', desc: 'Retailers delivery_type_id(instant/schedule/both) set by admin' }, format_with: :integer
          expose :delivery_type, documentation: { type: 'String', desc: 'Retailers delivery_type(instant/schedule/both) set by admin' }, format_with: :string
          expose :service_fee, documentation: { type: 'Float', desc: 'Service fee on delivery' }, format_with: :float
          expose :retailer_delivery_zone, using: API::V2::Retailers::Entities::ShowRetailerDeliveryZoneEntity, documentation: { type: 'retailer_delivery_zone', desc: 'retailer_delivery_zone' }
          expose :is_schedule, documentation: { type: 'Boolean', desc: 'Describes if retailer is opened for scheduled orders' }, format_with: :bool
          expose :vat, documentation: { type: 'Integer', desc: 'Value Added TAX %' }, format_with: :integer

          private

          def vat
            object.city.try(:vat)
          end

          def retailer_delivery_zone
            # rdzid = object.try('retailer_delivery_zones_id')
            # Rails.cache.fetch("#{rdzid}/retailer_delivery_zone", expires_in: 1.hours) do
            #   object.retailer_delivery_zones.find(rdzid).attributes unless rdzid.blank?
            # end
            # object.retailer_delivery_zones.find(rdzid) unless rdzid.blank?
            if object.try('retailer_delivery_zones_id')
              object.retailer_delivery_zones.find(object.try('retailer_delivery_zones_id'))
            else
              object.try('retailer_delivery_zone')
            end
          end

          def is_opened
            object.is_opened?
          end

          def is_schedule
            # Rails.cache.fetch("#{object.id}/is_schedule", expires_in: 1.hours) do
            object.is_opened
            # end
          end

          # def delivery_slots
          #   rdzid = object.try('retailer_delivery_zones_id')
          #
          #   # copied from delivery_slots/all api, this should move to some base class (interactors/service)
          #   skip_time = object.delivery_slot_skip_hours
          #   delivery_slots = DeliverySlot.where(retailer_delivery_zone_id: rdzid)
          #                                .where("start > #{Time.now.seconds_since_midnight + skip_time} AND day = #{Time.now.wday + 1} OR day = #{1.days.since.wday + 1}")
          # end

          def photo_url
            object.photo.url(:medium)
          end

          def average_rating
            object.average_rating
          end

          def min_basket_value
            object.try(:min_basket_value)
            # object.retailer_delivery_zones.maximum("min_basket_value")
          end

          def is_in_range
            !object.try(:delivery_zones_id).nil? ? true : false
          end

          def is_favourite
            if options[:shopper_id]
              Rails.cache.fetch("#{object.id}:#{options[:shopper_id]}/is_favourite", expires_in: 1.hours) do
                ShopperFavouriteRetailer.find_by(shopper_id: options[:shopper_id], retailer_id: object.id) ? true : false
              end
            else
              false
            end
          end
        end
      end
    end
  end
end