module API
  module V1
    module Favourites
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
          expose :min_basket_value, documentation: { type: 'Float', desc: 'Min basket value of retaiiler' }, format_with: :float
          expose :priority, documentation: { type: 'Integer', desc: 'Retailers priority set by admin' }, format_with: :integer
          expose :opening_time, documentation: { type: 'String', desc: 'Opening hours/opening days of the shop' }, format_with: :string
          expose :is_opened, documentation: {type: 'Boolean', desc: 'Describes if retailer is opened'}, format_with: :bool
          expose :available_payment_types, using: API::V1::Retailers::Entities::ShowPaymentTypeEntity, documentation: {type: 'show_payment_type', is_array: true }
          expose :is_in_range, documentation: {type: 'Boolean', desc: 'Describes if favourite retailer is in range'}, format_with: :bool
          expose :delivery_type_id, documentation: { type: 'Integer', desc: 'Retailers delivery_type_id(instant/schedule/both) set by admin' }, format_with: :integer
          expose :delivery_type, documentation: { type: 'String', desc: 'Retailers delivery_type(instant/schedule/both) set by admin' }, format_with: :string
          expose :service_fee, documentation: { type: 'Float', desc: 'Service fee on delivery' }, format_with: :float
          # expose :retailer_delivery_zones_id, documentation: { type: 'Integer', desc: 'retailer_delivery_zones_id to get schedule slots' }, format_with: :integer
          expose :retailer_delivery_zone, using: API::V2::Retailers::Entities::ShowRetailerDeliveryZoneEntity, documentation: { type: 'retailer_delivery_zone', desc: 'retailer_delivery_zone' }
          expose :is_schedule, documentation: {type: 'Boolean', desc: 'Describes if retailer is opened for scheduled orders'}, format_with: :bool
        
          private
          
          # def retailer_delivery_zones_id
          #   object.try('retailer_delivery_zones_id')
          # end
        
          def retailer_delivery_zone
            rdzid = object.try('retailer_delivery_zones_id')
            object.retailer_delivery_zones.find(rdzid) unless rdzid.blank?
          end
          
          def is_opened
            object.try("open_now") #|| object.is_opened?
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
        
          def opening_time
            will_reopen = object.try("will_reopen")
            unless will_reopen.blank?
              json = JSON.parse(object.opening_time)
              week_days_opening = json["opening_hours"][0]#week days
              week_days_closing = json["closing_hours"][0]
              thursday_opening = json["opening_hours"][1]#thursday
              thursday_closing = json["closing_hours"][1]
              friday_opening = json["opening_hours"][2]#friday
              friday_closing = json["closing_hours"][2]
              #if  [1,2,3,4,7].include? Time.now.wday + 1 
              # these commented should not commented actually.
              # if Time.now.wday + 1 == 5
                thursday_opening = Time.at(will_reopen).utc.strftime("%H:%M")
              # elsif Time.now.wday + 1 == 6
                friday_opening = Time.at(will_reopen).utc.strftime("%H:%M")
              # else
                week_days_opening = Time.at(will_reopen).utc.strftime("%H:%M")
              # end
              
              "{\"closing_hours\":[\"#{week_days_closing}\",\"#{thursday_closing}\",\"#{friday_closing}\"],\"opening_days\":[true,true,true],\"opening_hours\":[\"#{week_days_opening}\",\"#{thursday_opening}\",\"#{friday_opening}\"]}"
              # {"closing_hours":[week_days_closing,thursday_closing,friday_closing],'opening_days':[true,true,true],'opening_hours':[week_days_opening,thursday_opening,friday_opening]}
              #object.opening_time
            else
              object.opening_time
            end
          end
          
          def is_in_range
            !object.try(:delivery_zones_id).nil? ? true : false
          end
          
          def min_basket_value
            object.try("min_basket_value")
          end
        
          # these retailers are already favorite man
          def is_favourite
            # if options[:shopper_id]
            #   ShopperFavouriteRetailer.find_by(shopper_id: options[:shopper_id], retailer_id: object.id) ? true : false
            # else
            #   false
            # end
            # object.try("count_favorite").to_i > 0 ? true : false
            true
          end
        end                
      end
    end
  end
end