# frozen_string_literal: true

module API
  module V1
    module Retailers
      module Entities
        class ClickAndCollect < API::BaseEntity
          root 'retailers', 'retailer'

          def self.entity_name
            'show_retailer'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :parent_id, documentation: { type: 'Integer', desc: 'Parent id of store chain' }, format_with: :integer
          expose :company_name, documentation: { type: 'String', desc: 'Shop name' }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: "URL friendly name" }, format_with: :string
          expose :photo_url, documentation: { type: 'String', desc: "An URL directing to a photo of the shop." }, format_with: :string
          expose :photo1_url, documentation: { type: 'String', desc: "An URL directing to a photo of the shop." }, format_with: :string
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
          # expose :seo_data, documentation: {type: 'String', desc: "SEO Data"}, format_with: :string, if: Proc.new { |obj| options[:web] }

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
            object.try("open_now") #|| object.is_opened?
          end

          def delivery_fee
            object.try("delivery_fee")
          end

          def rider_fee
            object.try("rider_fee")
          end

          def categories
            object.rcategories.where(parent_id: nil).order(:priority).distinct
          end

          def opening_time
            json = JSON.parse(object.opening_time)
            week_days_opening = json["opening_hours"][0]#week days
            week_days_closing = json["closing_hours"][0]
            thursday_opening = json["opening_hours"][1]#thursday
            thursday_closing = json["closing_hours"][1]
            friday_opening = json["opening_hours"][2]#friday
            friday_closing = json["closing_hours"][2]

            if !(will_reopen = object.try("will_reopen")).blank?
              thursday_opening = Time.at(will_reopen).utc.strftime("%H:%M")
              friday_opening = Time.at(will_reopen).utc.strftime("%H:%M")
              week_days_opening = Time.at(will_reopen).utc.strftime("%H:%M")

              "{\"closing_hours\":[\"#{week_days_closing}\",\"#{thursday_closing}\",\"#{friday_closing}\"],\"opening_days\":[true,true,true],\"opening_hours\":[\"#{week_days_opening}\",\"#{thursday_opening}\",\"#{friday_opening}\"]}"
            elsif !(will_close = object.try("will_close")).blank?
              friday_closing = Time.at(will_close).utc.strftime("%H:%M")
              thursday_closing = Time.at(will_close).utc.strftime("%H:%M")
              week_days_closing = Time.at(will_close).utc.strftime("%H:%M")
              "{\"closing_hours\":[\"#{week_days_closing}\",\"#{thursday_closing}\",\"#{friday_closing}\"],\"opening_days\":[true,true,true],\"opening_hours\":[\"#{week_days_opening}\",\"#{thursday_opening}\",\"#{friday_opening}\"]}"
            else
              object.opening_time
            end
          end

          def min_basket_value
            object.try("min_basket_value")
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
            object.try("store_category_ids")
          end

          def distance
            object.try("distance")
          end

          def ranking
            object.try("priority")
          end

          def service_fee
            object.try("service_fee")
          end

          def retailer_group_name
            object.retailer_group&.name
          end
        end
      end
    end
  end
end