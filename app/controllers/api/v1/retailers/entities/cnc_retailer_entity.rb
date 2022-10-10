module API
  module V1
    module Retailers
      module Entities
        class CncRetailerEntity < API::BaseEntity
          root 'retailers', 'retailer'

          def self.entity_name
            'show_cc_retailer'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :parent_id, documentation: { type: 'Integer', desc: 'Parent id of store chain' }, format_with: :integer
          expose :company_name, documentation: { type: 'String', desc: 'Shop name' }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: 'URL friendly name' }, format_with: :string
          expose :photo_url, documentation: { type: 'String', desc: 'An URL directing to a photo of the shop.' }, format_with: :string
          expose :photo1_url, documentation: { type: 'String', desc: 'An URL directing to a photo of the shop.' }, format_with: :string
          expose :min_basket_value, documentation: { type: 'Float', desc: 'Min basket value of retaiiler' }, format_with: :float
          # expose :opening_time, documentation: { type: 'String', desc: 'Opening hours/opening days of the shop' }, format_with: :string
          expose :is_opened, documentation: {type: 'Boolean', desc: 'Describes if retailer is opened'}, format_with: :bool
          expose :is_show_recipe, documentation: {type: 'Boolean', desc: 'Describes if retailer is showing recipe banner'}, format_with: :bool
          expose :retailer_type, documentation: {type: 'Integer', desc: 'Describes the retailer type'}, format_with: :integer
          expose :available_payment_types, using: API::V1::Retailers::Entities::ShowPaymentTypeEntity, documentation: {type: 'show_payment_type', is_array: true }
          expose :retailer_delivery_type_id, as: :delivery_type_id, documentation: { type: 'Integer', desc: 'Retailers delivery_type_id(instant/schedule/both) set by admin' }, format_with: :integer
          expose :retailer_delivery_type, as: :delivery_type, documentation: { type: 'String', desc: 'Retailers delivery_type(instant/schedule/both) set by admin' }, format_with: :string
          expose :service_fee, documentation: { type: 'Float', desc: 'Service fee' }, format_with: :float
          # expose :is_schedule, documentation: {type: 'Boolean', desc: 'Describes if retailer is opened for scheduled orders'}, format_with: :bool
          expose :vat, documentation: { type: 'Integer', desc: 'Value Added TAX %' }, format_with: :integer
          expose :distance, documentation: { type: 'Float', desc: 'Ranking' }, format_with: :float
          # expose :ranking, documentation: { type: 'Integer', desc: 'Distance Form shopper' }, format_with: :integer
          expose :store_category_ids, as: :store_type, documentation: { type: 'store_category_ids', desc: 'Store Category ID', is_array: true }
          expose :retailer_group_id, documentation: { type: 'Integer', desc: 'Retailer Group Id' }, format_with: :integer
          expose :retailer_group_name, documentation: { type: 'String', desc: 'Retailer Group Name' }, format_with: :string
          expose :latitude, documentation: { type: 'Float', desc: 'Retailer latitude' }, format_with: :float
          expose :longitude, documentation: { type: 'Float', desc: 'Retailer longitude' }, format_with: :float
          expose :categories, using: API::V2::Categories::Entities::ShowEntity, documentation: {type: 'show_category', is_array: true }
          expose :delivery_slots, using: API::V1::DeliverySlots::Entities::IndexEntity, documentation: {type: 'show_delivery_slot', is_array: true }
          # expose :seo_data, documentation: {type: 'String', desc: "SEO Data"}, format_with: :string, if: Proc.new { |obj| options[:web] }
          expose :is_featured, as: :featured, documentation: { type: 'Boolean', desc: 'Featured Flag' }, format_with: :bool
          expose :with_stock_level, as: :inventory_controlled, documentation: { type: 'Boolean', desc: 'Inventory Control flag' }, format_with: :bool

          private

          def vat
            object.city.try(:vat)
          end

          def parent_id
            object.report_parent_id.to_i > 0 ? object.report_parent_id : object.id
          end

          # def retailer_type
          #   Retailer.retailer_types[object.retailer_type]
          # end

          def add_day
            object.cutoff_time.to_i > 0 ? true : false
          end

          def retailer_delivery_type
            Retailer.delivery_types.key(object.try('retailer_delivery_type'))
          end

          def retailer_delivery_type_id
            object.try('retailer_delivery_type')
          end

          def is_schedule
            object.is_opened
          end

          def is_opened
            object.try('open_now') || object.is_opened
          end

          def delivery_fee
            object.try('delivery_fee')
          end

          def rider_fee
            object.try('rider_fee')
          end

          def categories
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
                result = Category.get_categories(object.id).order(:priority)
                result = Category.joins(:retailer_categories).where(id: 1, retailer_categories: {retailer_id: object.id}) + result if result.select {|cat| cat.id == 1}.count < 1 && object.shops.where(is_promotional: true).count > 0
                result.to_a
              end
            end
            result
          end

          def category_slot_wise
            options[:category_slot_wise]
          end

          def delivery_slots
            # skip_time = object.delivery_slot_skip_hours
            # day_add = 1 + (object.cutoff_time.to_i > 0 ? 1 : 0) + ((Time.now.seconds_since_midnight >= object.cutoff_time.to_i and object.cutoff_time.to_i > 0 ) ? 1 : 0)
            # start_time = day_add > 1 ? 0 : Time.now.seconds_since_midnight
            ds = []
            if retailer_delivery_type_id != 1 and object.is_opened
              ds.push(DeliverySlot.new(id: 0, day: Time.now.wday + 1, start: 28800, end: 79200, products_limit: 0))
            end

            if retailer_delivery_type_id == 1
              ds = ds.push(object.next_available_slots_cc).flatten
            end
            ds
          end

          def opening_time
            json = JSON.parse(object.opening_time)
            week_days_opening = json['opening_hours'][0]#week days
            week_days_closing = json['closing_hours'][0]
            thursday_opening = json['opening_hours'][1]#thursday
            thursday_closing = json['closing_hours'][1]
            friday_opening = json['opening_hours'][2]#friday
            friday_closing = json['closing_hours'][2]

            if !(will_reopen = object.try('will_reopen')).blank?
              thursday_opening = Time.at(will_reopen).utc.strftime('%H:%M')
              friday_opening = Time.at(will_reopen).utc.strftime('%H:%M')
              week_days_opening = Time.at(will_reopen).utc.strftime('%H:%M')

              "{\"closing_hours\":[\"#{week_days_closing}\",\"#{thursday_closing}\",\"#{friday_closing}\"],\"opening_days\":[true,true,true],\"opening_hours\":[\"#{week_days_opening}\",\"#{thursday_opening}\",\"#{friday_opening}\"]}"
            elsif !(will_close = object.try('will_close')).blank?
              friday_closing = Time.at(will_close).utc.strftime('%H:%M')
              thursday_closing = Time.at(will_close).utc.strftime('%H:%M')
              week_days_closing = Time.at(will_close).utc.strftime('%H:%M')
              "{\"closing_hours\":[\"#{week_days_closing}\",\"#{thursday_closing}\",\"#{friday_closing}\"],\"opening_days\":[true,true,true],\"opening_hours\":[\"#{week_days_opening}\",\"#{thursday_opening}\",\"#{friday_opening}\"]}"
            else
              object.opening_time
            end
          end

          def min_basket_value
            object.try('min_basket_value')
          end

          def is_favourite
            false
          end

          def available_payment_types
            if options[:show_online_payment]
              object.click_and_collect_payment_types
            else
              object.click_and_collect_payment_types.select { |payment_type| payment_type.id != 3 }
            end
          end

          def store_category_ids
            object.try('store_category_ids')
          end

          def distance
            object.try('distance')
          end

          def ranking
            object.try('priority')
          end

          def service_fee
            object.try('service_fee')
          end

          def retailer_group_name
            object.retailer_group&.name
          end
        end
      end
    end
  end
end
