# frozen_string_literal: true

class RetailerOpeningHour < ActiveRecord::Base
  time_of_day_attr :open, :close
  belongs_to :retailer, optional: true
  belongs_to :retailer_delivery_zone, optional: true

  include RetailerOpenHours

  enum days: {
    sunday: 1,
    monday: 2,
    tuesday: 3,
    wednesday: 4,
    thursday: 5,
    friday: 6,
    saturday: 7
  }

  def days_array
    [
      { day: 1, name: 'sunday' },
      { day: 2, name: 'monday' },
      { day: 3, name: 'tuesday' },
      { day: 4, name: 'wednesday' },
      { day: 5, name: 'thursday' },
      { day: 6, name: 'friday' },
      { day: 7, name: 'saturday' }
    ]
  end

  def day_name
    case day
    when 1
      'sunday'
    when 2
      'monday'
    when 3
      'tuesday'
    when 4
      'wednesday'
    when 5
      'thursday'
    when 6
      'friday'
    when 7
      'saturday'
    end
  end

  def self.not_schedule_close?(retailer_delivery_zone_id)
    where("#{Time.now.seconds_since_midnight} between close AND open AND day = #{Time.now.wday + 1}")
      .where(retailer_delivery_zone_id: retailer_delivery_zone_id).blank?
  end

  def close_time
    # close / (60.0 * 60.0)
    TimeOfDayAttr.l(close)
  end

  def open_time
    # open / (60.0 * 60.0)
    TimeOfDayAttr.l(open)
  end
end
