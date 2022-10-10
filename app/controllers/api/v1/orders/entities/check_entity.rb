module API
  module V1
    module Orders
      module Entities
        class ShowRetailer < API::BaseEntity
          root 'retailers', 'retailer'
        
          def self.entity_name
            'show_retailer'
          end
        
          expose :id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :company_name, documentation: { type: 'String', desc: 'Shop name' }, format_with: :string
          expose :company_address, documentation: { type: 'String', desc: 'Shop address' }, format_with: :string
          expose :is_favourite, documentation: { type: "Boolean", desc: 'Determines if retailer is in favourites'}, format_with: :bool
          expose :average_rating, documentation: { type: 'Float', desc: 'Shop average rating' }, format_with: :float
          expose :photo_url, documentation: { type: 'String', desc: "An URL directing to a photo of the shop." }, format_with: :string
          expose :photo1_url, documentation: { type: 'String', desc: "An URL directing to a photo of the shop." }, format_with: :string
          expose :available_payment_types, using: API::V1::Retailers::Entities::ShowPaymentTypeEntity, documentation: {type: 'show_payment_type', is_array: true }
          expose :min_basket_value, documentation: { type: 'Float', desc: 'Shop average rating' }, format_with: :float
        
          expose :is_opened, documentation: {type: 'Boolean', desc: 'Describes if retailer is opened'}, format_with: :bool
          expose :delivery_type_id, documentation: { type: 'Integer', desc: 'Retailers delivery_type_id(instant/schedule/both) set by admin' }, format_with: :integer
          expose :delivery_type, documentation: { type: 'String', desc: 'Retailers delivery_type(instant/schedule/both) set by admin' }, format_with: :string
          expose :service_fee, documentation: { type: 'Float', desc: 'Service fee on delivery' }, format_with: :float
          expose :retailer_delivery_zone, using: API::V2::Retailers::Entities::ShowRetailerDeliveryZoneEntity, documentation: { type: 'retailer_delivery_zone', desc: 'retailer_delivery_zone' }
          expose :is_schedule, documentation: {type: 'Boolean', desc: 'Describes if retailer is opened for scheduled orders'}, format_with: :bool
        
          private
        
          def retailer_delivery_zone
            rdzid = object.try('retailer_delivery_zones_id')
            object.retailer_delivery_zones.find(rdzid) unless rdzid.blank?
          end
        
          def is_opened
            object.is_opened?
          end
        
          def is_schedule
            object.is_opened
          end
        
          # def delivery_slots
          #   rdzid = object.try('retailer_delivery_zones_id')
          #
          #   # copied from delivery_slots/all api, this should move to some base class (interactors/service)
          #   skip_time = object.delivery_slot_skip_hours
          #   delivery_slots = DeliverySlot.where(retailer_delivery_zone_id: rdzid)
          #       .where("start > #{Time.now.seconds_since_midnight + skip_time} AND day = #{Time.now.wday + 1} OR day = #{1.days.since.wday + 1}")
          # end
        
          # def photo_url
          #   object.photo.url
          # end
        
          def average_rating
            object.average_rating
          end
        
          def min_basket_value
            object.try(:min_basket_value)
          end
        
          def is_favourite
            if options[:shopper_id]
              ShopperFavouriteRetailer.find_by(shopper_id: options[:shopper_id], retailer_id: object.id) ? true : false
            else
              false
            end
          end
        end
        
        
        class ShowRetailers < API::BaseEntity
          def self.entity_name
            'show_retailers'
          end
          expose :retailer, using: API::V1::Orders::Entities::ShowRetailer, documentation: {type: 'show_retailer', is_hash: true }
          expose :unavailable_products, documentation: { type: 'Array', desc: "Array of unavailable products." }, format_with: :array
          expose :available_products do |instance, options|
            retailer = instance[:retailer]
            products = instance[:available_products]
            API::V1::Retailers::Entities::ShowProductEntity.represent products, options.merge(retailer_id: retailer[:id])
          end
        
          private
        
          def retailer_id
            object.retailer.id
          end
        
        end
        
        class CheckEntity < API::BaseEntity
          expose :retailers, using: API::V1::Orders::Entities::ShowRetailers, documentation: {type: 'show_retailers', is_array: true }
        end        
      end
    end
  end
end