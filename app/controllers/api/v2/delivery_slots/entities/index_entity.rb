# frozen_string_literal: true

module API
  module V2
    module DeliverySlots
      module Entities
        class IndexEntity < API::V1::DeliverySlots::Entities::ListEntity
          unexpose :start_time, :end_time, :estimated_delivery_at, :day, :date_and_day, :week_no
          expose :usid, documentation: { type: 'Integer', desc: 'Unique Slot Id' }, format_with: :integer
          expose :slot_start, as: :start_time, documentation: { type: 'DateTime', desc: 'Start Time of Slot ' }, format_with: :dateTime
          expose :slot_end, as: :end_time, documentation: { type: 'DateTime', desc: 'Slot End time' }, format_with: :dateTime
          expose :slot_start, as: :estimated_delivery_at, documentation: { type: 'DateTime', desc: 'Start Time of Slot ' }, format_with: :dateTime

          def slot_start
            @slot_start ||= if object.has_attribute?(:slot_start) && object.slot_start
                              object.slot_start
                            elsif est_delivery
                              est_delivery
                            else
                              object.calculate_start_time(Time.now, week)
                            end
          end

          def slot_end
            @slot_end = if object.has_attribute?(:slot_end) && object.slot_start
                          object.slot_end
                        else
                          object.calculate_end_time(slot_start)
                        end
          end

          def time_milli
            (slot_start.to_time.utc.to_f * 1000).floor
          end

          def usid
            Integer(object.try(:usid) || (slot_start.strftime('%Y') + (slot_start.to_date + 1.day).strftime('%V').ljust(2, '0') + object.id.to_s))
          end
        end
      end
    end
  end
end
