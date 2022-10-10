# frozen_string_literal: true

module API
  module V3
    module Retailers
      module Entities
        class ShowRetailer < API::BaseEntity
          root 'retailers', 'retailer'

          def self.entity_name
            'show_retailer'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :parent_id, documentation: { type: 'Integer', desc: 'Parent id of store chain' }, format_with: :integer
          expose :company_name, documentation: { type: 'String', desc: 'Shop name' }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: 'URL friendly name' }, format_with: :string
          expose :company_address, documentation: { type: 'String', desc: 'Shop address' }, format_with: :string
          expose :is_favourite, documentation: { type: 'Boolean', desc: 'Determines if retailer is in favourites' }, format_with: :bool
          expose :average_rating, documentation: { type: 'Float', desc: 'Shop average rating' }, format_with: :float
          expose :photo_url, documentation: { type: 'String', desc: 'An URL directing to a photo of the shop.' }, format_with: :string
          expose :photo1_url, documentation: { type: 'String', desc: 'An URL directing to a photo of the shop.' }, format_with: :string
          expose :min_basket_value, documentation: { type: 'Float', desc: 'Min basket value of retaiiler' }, format_with: :float
          expose :priority, documentation: { type: 'Integer', desc: 'Retailers priority set by admin' }, format_with: :integer
          expose :opening_time, documentation: { type: 'String', desc: 'Opening hours/opening days of the shop' }, format_with: :string
          expose :is_opened, documentation: { type: 'Boolean', desc: 'Describes if retailer is opened' }, format_with: :bool
          expose :is_show_recipe, documentation: { type: 'Boolean', desc: 'Describes if retailer is showing recipe banner' }, format_with: :bool
          expose :retailer_type, documentation: { type: 'Integer', desc: 'Describes the retailer type' }, format_with: :integer
          expose :categories, using: API::V2::Categories::Entities::ShowEntity, documentation: { type: 'show_category', is_array: true }
          #expose :product_categories, as: :categories1, documentation: {type: 'show_category', is_array: true }
          expose :available_payment_types, using: API::V1::Retailers::Entities::ShowPaymentTypeEntity, documentation: { type: 'show_payment_type', is_array: true }
          expose :retailer_delivery_type_id, as: :delivery_type_id, documentation: { type: 'Integer', desc: 'Retailers delivery_type_id(instant/schedule/both) set by admin' }, format_with: :integer
          expose :retailer_delivery_type, as: :delivery_type, documentation: { type: 'String', desc: 'Retailers delivery_type(instant/schedule/both) set by admin' }, format_with: :string
          expose :service_fee, documentation: { type: 'Float', desc: 'Service fee on delivery' }, format_with: :float
          expose :retailer_delivery_zone, using: API::V3::Retailers::Entities::ShowRetailerDeliveryZoneEntity, documentation: { type: 'retailer_delivery_zone', desc: 'retailer_delivery_zone' }
          expose :top_searches, documentation: { type: 'String', is_array: true }
          expose :is_schedule, documentation: { type: 'Boolean', desc: 'Describes if retailer is opened for scheduled orders' }, format_with: :bool
          expose :delivery_slots, using: API::V1::DeliverySlots::Entities::IndexEntity, documentation: { type: 'show_delivery_slot', is_array: true }
          expose :vat, documentation: { type: 'Integer', desc: 'Value Added TAX %' }, format_with: :integer
          expose :add_day, documentation: { type: 'Boolean', desc: 'Determines if retailer has cutoff_time or not' }, format_with: :bool
          expose :longitude, documentation: { type: 'Float', desc: 'longitude' }, format_with: :float
          expose :latitude, documentation: { type: 'Float', desc: 'latitude' }, format_with: :float
          expose :city, documentation: { type: 'String', desc: 'City name' }, format_with: :string
          expose :store_category_ids, as: :store_type, documentation: { type: 'store_category_ids', desc: 'Store Category ID', is_array: true }
          expose :retailer_group_id, documentation: { type: 'Integer', desc: 'Retailer Group ID' }, format_with: :integer
          expose :retailer_group_name, documentation: { type: 'String', desc: 'Retailer Group Name' }, format_with: :string
          expose :seo_data, documentation: { type: 'String', desc: 'SEO Data' }, format_with: :string, if: Proc.new { |obj| options[:web] }
          expose :is_featured, as: :featured, documentation: { type: 'Boolean', desc: 'Featured Flag' }, format_with: :bool
          expose :with_stock_level, as: :inventory_controlled, documentation: { type: 'Boolean', desc: 'Inventory Control flag' }, format_with: :bool

          private

          def vat
            object.city.try(:vat)
          end

          def store_category_ids
            object.try('store_category_ids').to_a.uniq
          end

          def parent_id
            object.report_parent_id.to_i > 0 ? object.report_parent_id : object.id
          end

          # def retailer_type
          #   Retailer.retailer_types[object.retailer_type]
          # end

          def city
            object.city.try(:slug)
          end

          def add_day
            object.cutoff_time.to_i > 0 ? true : false
          end

          def retailer_delivery_zone_id
            object.try('retailer_delivery_zones_id')
          end

          def retailer_delivery_zone
            #rdzid = object.try('retailer_delivery_zones_id')
            #object.retailer_delivery_zones.find(rdzid) unless rdzid.blank?
            {
              id: retailer_delivery_zone_id,
              min_basket_value: min_basket_value,
              delivery_fee: delivery_fee,
              rider_fee: rider_fee
            }
          end

          def retailer_delivery_type
            Retailer.delivery_types.key(object.try('retailer_delivery_type'))
          end

          def retailer_delivery_type_id
            object.try('retailer_delivery_type')
          end

          def is_opened
            object.try('open_now') #|| object.is_opened?
          end

          def is_schedule
            # Rails.cache.fetch("#{object.id}/is_schedule", expires_in: 3.minutes) do
            # object.is_opened && (delivery_slots && delivery_slots.length > 0)
            object.is_opened
            # end
          end

          def delivery_slots
            rdzid = object.try('retailer_delivery_zones_id')
            object.next_available_slots.select { |avs| avs.retailer_delivery_zone_id == rdzid } #.first].compact

            # copied from delivery_slots/all api, this should move to some base class (interactors/service)
            # skip_time = object.delivery_slot_skip_hours
            # day_add = 1 + (object.cutoff_time.to_i > 0 ? 1 : 0) + ((Time.now.seconds_since_midnight >= object.cutoff_time.to_i and object.cutoff_time.to_i > 0 ) ? 1 : 0)
            # start_time = day_add > 1 ? 0 : Time.now.seconds_since_midnight

            # #DeliverySlot.where(retailer_delivery_zone_id: rdzid).where("start > #{Time.now.seconds_since_midnight + skip_time} AND day = #{Time.now.wday + 1} OR day = #{1.days.since.wday + 1}")
            # if options[:next_slot]
            #   Rails.cache.fetch("#{object.id}/retailer_delivery_zone_id/two_week_slots", expires_in: 15.minutes) do
            #     @delivery_slots ||= DeliverySlot.slots_for_six_days(object.id,rdzid,skip_time,day_add,0,(Time.now.seconds_since_midnight >= object.cutoff_time.to_i and object.cutoff_time.to_i > 0 ),start_time)
            #     dslots = @delivery_slots.select{ |ds| ds.day >= Time.now.wday + day_add }.sort_by { |ds| [ds.day,ds.start] }.first
            #     if dslots
            #       @delivery_slots = [dslots]
            #     else
            #       dslots = @delivery_slots.select{ |ds| ds.day < Time.now.wday + day_add }.sort_by { |ds| [ds.day,ds.start] }.first
            #       dslots ? @delivery_slots = [dslots] :  @delivery_slots = []
            #     end
            #   end
            # else
            #   @delivery_slots ||= DeliverySlot.get_slots(object.id,rdzid,skip_time,day_add,0,(Time.now.seconds_since_midnight >= object.cutoff_time.to_i and object.cutoff_time.to_i > 0 ),start_time).limit(1)
            #   if @delivery_slots.length < 1
            #     day_add += 1
            #     @delivery_slots = DeliverySlot.get_slots(object.id,rdzid,skip_time,day_add,0,(Time.now.seconds_since_midnight >= object.cutoff_time.to_i and object.cutoff_time.to_i > 0 ),start_time).limit(1)
            #   end
            # end
            # @delivery_slots
          end

          def categories
            result = []
            if category_slot_wise
              result = Rails.cache.fetch("list/#{object.id}/categories/limit/1000/offset/0", expires_in: 15.minutes) do
                delivery_time = retailer_delivery_type_id.to_i == 1 ? (delivery_slots.first.slot_date.to_time) : Time.now rescue Time.now
                delivery_time = (delivery_time.utc.to_f * 1000).floor
                result = Category.categories_list(object.id, delivery_time)
                if result.select { |cat| cat.id == 1 }.length < 1 and object.shop_promotions.where('? between start_time and end_time', delivery_time).count > 0
                  result = Category.joins(:retailer_categories).where(id: 1, retailer_categories: { retailer_id: object.id }) + result
                end
                result.to_a
              end
            else
              result = Rails.cache.fetch("#{object.id}/categories/limit/1000/offset/0", expires_in: 15.minutes) do
                # if object.is_opened? || object.delivery_type_id != 0
                # cats = object.rcategories.where(parent_id: nil).order(:priority).distinct #.joins(:retailer_categories).where("retailer_categories.retailer_id = #{object.id}").where('products.brand_id is not null').order(:priority).distinct
                # cats = [Category.find_by(id: 1)] + cats if promotional > 0
                # cats = Category.get_categories(object.id).order(:priority)
                #Category.get_categories(object.id).order(:priority)
                result = Category.get_categories(object.id).order(:priority)
                result = Category.joins(:retailer_categories).where(id: 1, retailer_categories: { retailer_id: object.id }) + result if result.select { |cat| cat.id == 1 }.count < 1 && object.shops.where(is_promotional: true).count > 0
                result.to_a
                # cats.to_a
                #::CategoriesEndpointService.result(ActionController::Parameters.new({retailer_id: object.id}))[:categories]
                # end
              end
            end
            result
          end

          def category_slot_wise
            options[:category_slot_wise]
          end

          def promotional
            object.try('promotional').to_i
          end

          def opening_time
            json = JSON.parse(object.opening_time)
            week_days_opening = json['opening_hours'][0] #week days
            week_days_closing = json['closing_hours'][0]
            thursday_opening = json['opening_hours'][1] #thursday
            thursday_closing = json['closing_hours'][1]
            friday_opening = json['opening_hours'][2] #friday
            friday_closing = json['closing_hours'][2]

            if !(will_reopen = object.try('will_reopen')).blank?
              #if  [1,2,3,4,7].include? Time.now.wday + 1
              # these commented should not commented actually.
              # if Time.now.wday + 1 == 5
              thursday_opening = Time.at(will_reopen).utc.strftime('%H:%M')
              # elsif Time.now.wday + 1 == 6
              friday_opening = Time.at(will_reopen).utc.strftime('%H:%M')
              # else
              week_days_opening = Time.at(will_reopen).utc.strftime('%H:%M')
              # end

              "{\"closing_hours\":[\"#{week_days_closing}\",\"#{thursday_closing}\",\"#{friday_closing}\"],\"opening_days\":[true,true,true],\"opening_hours\":[\"#{week_days_opening}\",\"#{thursday_opening}\",\"#{friday_opening}\"]}"
              # {"closing_hours":[week_days_closing,thursday_closing,friday_closing],'opening_days':[true,true,true],'opening_hours':[week_days_opening,thursday_opening,friday_opening]}
              #object.opening_time
              # elsif !(roh = RetailerOpeningHour.where(retailer_delivery_zone_id: object.try(:delivery_zones_id).to_i, day: Time.now.wday + 1).where('close>?',Time.now.seconds_since_midnight)).blank?
            elsif !(will_close = object.try('will_close')).blank?
              #(delivery_zones_id = object.try(:delivery_zones_id)).blank?
              friday_closing = Time.at(will_close).utc.strftime('%H:%M')
              thursday_closing = Time.at(will_close).utc.strftime('%H:%M')
              week_days_closing = Time.at(will_close).utc.strftime('%H:%M')
              "{\"closing_hours\":[\"#{week_days_closing}\",\"#{thursday_closing}\",\"#{friday_closing}\"],\"opening_days\":[true,true,true],\"opening_hours\":[\"#{week_days_opening}\",\"#{thursday_opening}\",\"#{friday_opening}\"]}"
            else
              object.opening_time
            end
          end

          def top_searches
            # Rails.cache.fetch("#{object.id}/#{I18n.locale}/top_searches", expires_in: 3.hours) do
            # #if object.created_at <= 30.days.ago
            #   searches = Searchjoy::Search.where(retailer_id: object.id,language: I18n.locale).where('created_at > ?', 30.days.ago).group(:query).order("count(query) desc").limit(20).pluck(:query)
            #   if searches && searches.count > 5
            #     searches
            #   else
            #     if I18n.locale == :ar
            #       ['حليب', 'ماء', 'خبز', 'آيس كريم', 'موز', 'طماطم', 'قهوة', 'بيض', 'دجاج', 'جوز الهند', 'جبنة', 'بصل', 'ليمون', 'نسكافيه', 'أرز', 'تونة', 'خيار', 'شاي', 'محارم', 'زبدة', 'فشار', 'سكر']
            #     else
            #       ['milk','water','bread','ice cream','banana','tomato','coffee','eggs','chicken','coconut','cheese','onion','lemon','nescafe','rice','tuna','cucumber','tea','tissue','butter','popcorn sugar']
            #     end
            #   end
            #   #Searchjoy::Search.where(retailer_id: object.id).where('created_at > ?', 30.days.ago).group(:query).order("count(query) desc").having('count(query) > 2').limit(20).pluck(:query)
            #   #Searchjoy::Search.where(retailer_id: object.id).where('created_at > ?', 30.days.ago).group(:query).order("count(query) desc").having("(select count(*) from products where lower(name) like lower('%#{:query}%')) > 0").limit(20).pluck(:query)
            # #end
            # end
            []
          end

          def min_basket_value
            object.try('min_basket_value')
          end

          def delivery_fee
            object.try('delivery_fee')
          end

          def rider_fee
            object.try('rider_fee')
          end

          def is_favourite
            # if options[:shopper_id]
            #   ShopperFavouriteRetailer.find_by(shopper_id: options[:shopper_id], retailer_id: object.id) ? true : false
            # else
            #   false
            # end
            # object.try("count_favorite").to_i > 0 ? true : false
            false
          end

          def available_payment_types
            if options[:show_online_payment]
              object.delivery_payment_types
            else
              object.delivery_payment_types.select { |payment_type| payment_type.id != 3 }
            end
          end

          def retailer_group_name
            object.retailer_group&.name
          end
        end
      end
    end
  end
end
