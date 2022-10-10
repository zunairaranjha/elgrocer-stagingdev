class RetailerHasService < ActiveRecord::Base
  time_of_day_attr :delivery_slot_skip_time, :cutoff_time, :schedule_order_reminder_time
  belongs_to :retailer, optional: true
  belongs_to :retailer_service, optional: true
  validates_presence_of :retailer

  scope :click_and_collect, -> { where(retailer_service_id: 2) }
  scope :delivery, -> { where(retailer_service_id: 1) }

  def order_cutoff_time
    #cutoff_time/ (60.0 * 60.0)
    TimeOfDayAttr.l(cutoff_time)
  end

  def schedule_order_reminder_hours
    # open / (60.0 * 60.0)
    TimeOfDayAttr.l(schedule_order_reminder_time) #unless schedule_order_reminder_hours.blank?
  end

  def delivery_slot_skip_hours
    # close / (60.0 * 60.0)
    TimeOfDayAttr.l(delivery_slot_skip_time) #unless delivery_slot_skip_hours.blank?
  end

  enum delivery_type: {
    instant: 0,
    schedule: 1,
    instant_and_schedule: 2
  }

end
