# frozen_string_literal: true

module API
  module V1
    module DeliverySlots
      module Entities
        class IndexEntity < API::BaseEntity
          root 'delivery_slots', 'delivery_slot'

          def self.entity_name
            'show_delivery_slot'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID' }, format_with: :integer
          expose :day, documentation: { type: 'Integer', desc: 'Week Day number' }, format_with: :integer
          expose :date_and_day, as: :day_name, documentation: { type: 'String', desc: 'Week Day name' }, format_with: :string
          expose :start_time, documentation: { type: 'String', desc: 'Start Time' }, format_with: :string
          expose :end_time, documentation: { type: 'String', desc: 'End Time' }, format_with: :string
          expose :products_limit, documentation: { type: 'Integer', desc: 'Products Limit' }, format_with: :integer
          expose :orders_limit, documentation: { type: 'Integer', desc: 'Orders Limit' }, format_with: :integer
          expose :estimated_delivery_at, documentation: { type: 'String', desc: 'Date of ordering' }, format_with: :string
          expose :total_products, documentation: { type: 'Integer', desc: 'Products present in delivery_slot' }, format_with: :integer
          expose :week_no, as: :week, documentation: { type: 'Integer', desc: 'Week number of the slots' }, format_with: :integer
          expose :time_milli, documentation: { type: 'Float', desc: 'Time in Millis' }, format_with: :float

          def estimated_delivery_at
            return @estimated_delivery if @estimated_delivery

            @estimated_delivery = if week.positive?
                                    object.calculate_estd_delivery(c_time || Time.now, week)
                                  else
                                    est_delivery || object.calculate_estimated_delivery_at(Time.now)
                                  end
          end

          def date_and_day
            estimated_delivery_at.strftime('%a %b %d')
          end

          def total_products
            object.try(:total_products)
          end

          def week
            @week ||= options[:week].to_i.positive? ? options[:week].to_i : object.try(:week).to_i
          end

          def week_no
            if est_delivery
              (est_delivery + 1.day).strftime('%V').to_i
            else
              options[:from_ios] && (week < 10) ? week + 60 : week
            end
          end

          def c_time
            options[:c_time]
          end

          def est_delivery
            options[:estimated_delivery]
          end

          def time_milli
            (estimated_delivery_at.to_time.utc.to_f * 1000).floor
          end

        end
      end
    end
  end
end
