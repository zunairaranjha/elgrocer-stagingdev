class RetailerDeliveryZone < ActiveRecord::Base
  time_of_day_attr :delivery_slot_skip_time, :cutoff_time
  attr_readonly :rdz_name
  belongs_to :retailer, optional: true, touch: true
  belongs_to :delivery_zone, optional: true
  has_many :retailer_opening_hours
  has_many :delivery_slots
  has_many :available_slots
  has_many :next_available_slots, -> { where(slot_rank: 1).order(:slot_date) }, class_name: 'AvailableSlot' #, source: :available_slots
  has_many :orders

  accepts_nested_attributes_for :retailer_opening_hours, allow_destroy: true
  accepts_nested_attributes_for :delivery_slots, allow_destroy: true

  enum delivery_type: {
    instant: 0,
    schedule: 1,
    instant_and_schedule: 2
  }

  def order_cutoff_time
    TimeOfDayAttr.l(cutoff_time)
  end

  def delivery_slot_skip_hours
    TimeOfDayAttr.l(delivery_slot_skip_time)
  end

  def name
    self.try(:rdz_name) || "#{retailer.try(:company_name)} : #{delivery_zone.try(:name)}"
  end
end
