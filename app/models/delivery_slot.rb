class DeliverySlot < ActiveRecord::Base
  attr_accessor :slot_interval
  time_of_day_attr :start, :end

  validates_presence_of :day
  validate :valid_start_and_end_time

  belongs_to :retailer_delivery_zone, optional: true
  has_many :orders
  belongs_to :retailer_service, optional: true
  belongs_to :retailer, optional: true
  scope :click_and_collect, -> { where(retailer_service_id: 2) }
  scope :active, -> { where(is_active: true) }
  scope :with_service, ->(service) { where(retailer_service_id: service) }
  scope :with_zone, ->(zone) { where(retailer_delivery_zone_id: zone) }

  def name
    "#{day_name[0..2]} #{start_time}-#{end_time}"
  end

  def valid_start_and_end_time
    if (start && self.end) && (self.end < start)
      errors.add(:end, 'must be greater than start')
    end
  end

  enum days: {
    sunday: 1,
    monday: 2,
    tuesday: 3,
    wednesday: 4,
    thursday: 5,
    friday: 6,
    saturday: 7
  }

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

  def start_time
    # close / (60.0 * 60.0)
    TimeOfDayAttr.l(start)
  end

  def end_time
    # open / (60.0 * 60.0)
    TimeOfDayAttr.l(self.end)
  end

  def calculate_start_time(input, week)
    c_year = week > 52 ? input.beginning_of_week.strftime('%Y').to_i : input.strftime('%Y').to_i
    date = Date.commercial(c_year, week) + start.second
    date + (day - 2).day
  end

  def calculate_end_time(input)
    input + (self.end - start).second
  end

  def calculate_estimated_delivery_at(input)
    # (input + ((7 - (input.wday + 1 - day).abs) % 7).day).beginning_of_day + start.second
    date = input.beginning_of_week.beginning_of_day + start.second
    #date = date + ((day - date.wday+1) % 7)
    date = date + (day - 2).day
    delta = date > input ? 0 : 7
    date = date + delta.day
  end

  def calculate_estd_delivery(input, week = (Time.now + 1.day).strftime('%V').to_i)
    # c_year = input.strftime('%V').to_i
    # c_year = (c_year > 50 and c_year > week) ? input.strftime('%Y').to_i + 1 : input.strftime('%Y').to_i
    # c_year = week > 52 ? c_year - 1 : c_year
    c_year = week > 52 ? input.beginning_of_week.strftime('%Y').to_i : input.strftime('%Y').to_i
    date = Date.commercial(c_year, week) + start.second
    date = date + (day - 2).day
  end

  def delivery_at
    calculate_estimated_delivery_at(Time.now)
  end

  def ampm_range
    startTime = (Time.now.beginning_of_day + start.seconds).strftime('%I:%M %p')
    endTime = (Time.now.beginning_of_day + self.end.seconds).strftime('%I:%M %p')
    "#{startTime} - #{endTime}"
  end

  def schedule_for(input)
    dayAttr = ''
    dayAttr = I18n.t('order_placement.today') if input.today?
    dayAttr = I18n.t('order_placement.tomorrow') if input.to_date == Date.tomorrow

    "#{dayAttr}#{input.to_date.to_s('%Y %m %d')}, #{ampm_range}"
  end

  def self.get_slots(retailer_id, retailer_delivery_zone_id, skip_time, day_add, items_count = 0, skip_next = false, start_time = Time.now.seconds_since_midnight)
    first_day = Time.now.wday + day_add > 7 ? Time.now.wday + day_add - 7 : Time.now.wday + day_add
    second_day = 1.days.since.wday + (skip_next ? day_add - 1 : day_add) > 7 ? 1.days.since.wday + (skip_next ? day_add - 1 : day_add) - 7 : 1.days.since.wday + (skip_next ? day_add - 1 : day_add)
    slot_sort = (first_day == 7) ? 'DESC' : 'ASC'
    DeliverySlot.joins("join (SELECT SUM(products_limit)*MIN(products_limit)/GREATEST(MIN(products_limit),1) total_limit, SUM(products_limit_margin) total_margin, SUM(orders_limit)*MIN(orders_limit)/GREATEST(MIN(orders_limit),1) total_orders_limit, start dsstart, day dsday FROM delivery_slots, retailer_delivery_zones sub_rdz WHERE retailer_delivery_zone_id = sub_rdz.id AND sub_rdz.retailer_id = #{retailer_id} AND day in (#{first_day},#{second_day}) AND delivery_slots.is_active = 't' group by start, day) AS totals on totals.dsstart = delivery_slots.start and totals.dsday = delivery_slots.day")
                .joins('join delivery_slots ds on ds.start = delivery_slots.start and ds.day = delivery_slots.day').joins("join retailer_delivery_zones rdz on rdz.id = ds.retailer_delivery_zone_id and rdz.retailer_id = #{retailer_id}")
                .joins("left outer join orders on orders.delivery_slot_id = ds.id and status_id != 4 and date(estimated_delivery_at) >= '#{Time.now.to_date}'").joins('left outer join order_positions on order_positions.order_id = orders.id')
                .where(retailer_delivery_zone_id: retailer_delivery_zone_id).where(" delivery_slots.is_active = 't' AND delivery_slots.start > #{start_time + skip_time} AND delivery_slots.day = #{first_day} OR delivery_slots.day = #{second_day}").select('delivery_slots.*, coalesce(sum(order_positions.amount),0) AS total_products, totals.total_limit, totals.total_margin, count(distinct orders.id) AS total_orders, totals.total_orders_limit').group('delivery_slots.id, totals.total_limit, totals.total_margin, totals.total_orders_limit')
                .having("delivery_slots.is_active = 't' and (totals.total_orders_limit = 0 or totals.total_orders_limit > count(distinct orders.id)) and (totals.total_limit = 0 or (totals.total_limit > coalesce(sum(order_positions.amount),0) and (((coalesce(sum(order_positions.amount),0)/(totals.total_limit * 1.0 )) <= 0.7) or totals.total_limit + totals.total_margin >= coalesce(sum(order_positions.amount),0) + #{items_count})))")
                .order("delivery_slots.day #{slot_sort}", 'delivery_slots.start')
  end

  def self.slots_for_two_weeks(retailer_id, retailer_delivery_zone_id, skip_time, day_add, items_count = 0, skip_next = false, start_time = Time.now.seconds_since_midnight, limit = false)
    if Time.now.wday + day_add > 7
      first_day = Time.now.wday + day_add - 7
      first_week = (Time.now + 1.day).strftime('%V').to_i + 1
    else
      first_day = Time.now.wday + day_add
      first_week = (Time.now + 1.day).strftime('%V').to_i
    end
    first_week = (first_week > 53 ? first_week % 53 : first_week)
    second_week = ((first_week + 1) > 53 ? (first_week + 1) % 53 : first_week + 1)
    third_week = ((first_week + 2) > 53 ? (first_week + 2) % 53 : first_week + 2)
    rem_days = [1, 2, 3, 4, 5, 6, 7, 8]
    rem_days.shift(first_day)
    sql1 = DeliverySlot.joins("join (SELECT SUM(products_limit)*MIN(products_limit)/GREATEST(MIN(products_limit),1) total_limit, SUM(products_limit_margin) total_margin, SUM(orders_limit)*MIN(orders_limit)/GREATEST(MIN(orders_limit),1) total_orders_limit, start dsstart, day dsday FROM delivery_slots, retailer_delivery_zones sub_rdz WHERE retailer_delivery_zone_id = sub_rdz.id AND sub_rdz.retailer_id = #{retailer_id} AND delivery_slots.is_active = 't' group by start, day) AS totals on totals.dsstart = delivery_slots.start and totals.dsday = delivery_slots.day")
                       .joins('join delivery_slots ds on ds.start = delivery_slots.start and ds.day = delivery_slots.day').joins("join retailer_delivery_zones rdz on rdz.id = ds.retailer_delivery_zone_id and rdz.retailer_id = #{retailer_id}")
                       .joins("left outer join orders on orders.delivery_slot_id = ds.id and status_id not in (-1, 4) and extract(year from estimated_delivery_at) =  #{Time.now.strftime('%Y')} and extract(week from estimated_delivery_at  + '1 day'::interval) = #{first_week} ").joins('left outer join order_positions on order_positions.order_id = orders.id')
                       .where(retailer_delivery_zone_id: retailer_delivery_zone_id).where(" delivery_slots.is_active = 't' AND delivery_slots.start > #{start_time + skip_time} AND delivery_slots.day = #{first_day} OR delivery_slots.day in (#{rem_days.join(',')}) ").select("delivery_slots.*, coalesce(sum(order_positions.amount),0) AS total_products, totals.total_limit, totals.total_margin, count(distinct orders.id) AS total_orders, totals.total_orders_limit, #{first_week} as week ").group('delivery_slots.id, totals.total_limit, totals.total_margin, totals.total_orders_limit')
                       .having("delivery_slots.is_active = 't' and (totals.total_orders_limit = 0 or totals.total_orders_limit > count(distinct orders.id)) and (totals.total_limit = 0 or (totals.total_limit > coalesce(sum(order_positions.amount),0) and (((coalesce(sum(order_positions.amount),0)/(totals.total_limit * 1.0 )) <= 0.7) or totals.total_limit + totals.total_margin >= coalesce(sum(order_positions.amount),0) + #{items_count})))")
                       .order('delivery_slots.day', 'delivery_slots.start').to_sql
    sql2 = DeliverySlot.joins("join (SELECT SUM(products_limit)*MIN(products_limit)/GREATEST(MIN(products_limit),1) total_limit, SUM(products_limit_margin) total_margin, SUM(orders_limit)*MIN(orders_limit)/GREATEST(MIN(orders_limit),1) total_orders_limit, start dsstart, day dsday FROM delivery_slots, retailer_delivery_zones sub_rdz WHERE retailer_delivery_zone_id = sub_rdz.id AND sub_rdz.retailer_id = #{retailer_id} AND delivery_slots.is_active = 't' group by start, day) AS totals on totals.dsstart = delivery_slots.start and totals.dsday = delivery_slots.day")
                       .joins('join delivery_slots ds on ds.start = delivery_slots.start and ds.day = delivery_slots.day').joins("join retailer_delivery_zones rdz on rdz.id = ds.retailer_delivery_zone_id and rdz.retailer_id = #{retailer_id}")
                       .joins("left outer join orders on orders.delivery_slot_id = ds.id and status_id not in (-1, 4) and extract(year from estimated_delivery_at) =  #{Time.now.strftime('%Y')} and extract(week from estimated_delivery_at  + '1 day'::interval) = #{second_week} ").joins('left outer join order_positions on order_positions.order_id = orders.id')
                       .where(retailer_delivery_zone_id: retailer_delivery_zone_id).where("delivery_slots.is_active = 't'").select("delivery_slots.*, coalesce(sum(order_positions.amount),0) AS total_products, totals.total_limit, totals.total_margin, count(distinct orders.id) AS total_orders, totals.total_orders_limit,  #{second_week} as week ").group('delivery_slots.id, totals.total_limit, totals.total_margin, totals.total_orders_limit')
                       .having("delivery_slots.is_active = 't' and (totals.total_orders_limit = 0 or totals.total_orders_limit > count(distinct orders.id)) and (totals.total_limit = 0 or (totals.total_limit > coalesce(sum(order_positions.amount),0) and (((coalesce(sum(order_positions.amount),0)/(totals.total_limit * 1.0 )) <= 0.7) or totals.total_limit + totals.total_margin >= coalesce(sum(order_positions.amount),0) + #{items_count})))")
                       .order('delivery_slots.day', 'delivery_slots.start').to_sql
    sql3 = DeliverySlot.joins("join (SELECT SUM(products_limit)*MIN(products_limit)/GREATEST(MIN(products_limit),1) total_limit, SUM(products_limit_margin) total_margin, SUM(orders_limit)*MIN(orders_limit)/GREATEST(MIN(orders_limit),1) total_orders_limit, start dsstart, day dsday FROM delivery_slots, retailer_delivery_zones sub_rdz WHERE retailer_delivery_zone_id = sub_rdz.id AND sub_rdz.retailer_id = #{retailer_id} AND delivery_slots.is_active = 't' group by start, day) AS totals on totals.dsstart = delivery_slots.start and totals.dsday = delivery_slots.day")
                       .joins('join delivery_slots ds on ds.start = delivery_slots.start and ds.day = delivery_slots.day').joins("join retailer_delivery_zones rdz on rdz.id = ds.retailer_delivery_zone_id and rdz.retailer_id = #{retailer_id}")
                       .joins("left outer join orders on orders.delivery_slot_id = ds.id and status_id not in (-1, 4) and extract(year from estimated_delivery_at) =  #{Time.now.strftime('%Y')} and extract(week from estimated_delivery_at  + '1 day'::interval) = #{third_week} ").joins('left outer join order_positions on order_positions.order_id = orders.id')
                       .where(retailer_delivery_zone_id: retailer_delivery_zone_id).where("delivery_slots.is_active = 't'").select("delivery_slots.*, coalesce(sum(order_positions.amount),0) AS total_products, totals.total_limit, totals.total_margin, count(distinct orders.id) AS total_orders, totals.total_orders_limit,  #{third_week} as week ").group('delivery_slots.id, totals.total_limit, totals.total_margin, totals.total_orders_limit')
                       .having("delivery_slots.is_active = 't' and (totals.total_orders_limit = 0 or totals.total_orders_limit > count(distinct orders.id)) and (totals.total_limit = 0 or (totals.total_limit > coalesce(sum(order_positions.amount),0) and (((coalesce(sum(order_positions.amount),0)/(totals.total_limit * 1.0 )) <= 0.7) or totals.total_limit + totals.total_margin >= coalesce(sum(order_positions.amount),0) + #{items_count})))")
                       .order('delivery_slots.day', 'delivery_slots.start').to_sql
    delivery_slots = DeliverySlot.find_by_sql("(#{sql1}) UNION ALL (#{sql2}) UNION ALL (#{sql3}) LIMIT #{limit ? 1 : 36 }")
    # delivery_slots = limit ? DeliverySlot.find_by_sql("(#{sql1}) UNION ALL (#{sql2}) LIMIT 1") : DeliverySlot.find_by_sql("(#{sql1}) UNION ALL (#{sql2})")
    delivery_slots
  end

  def self.cnc_slots(retailer_id, skip_time, day_add, items_count = 0, skip_next = false, start_time = Time.now.seconds_since_midnight, for_checkout = false)
    if Time.now.wday + day_add > 7
      first_day = Time.now.wday + day_add - 7
      first_week = (Time.now + 1.day).strftime('%V').to_i + 1
    else
      first_day = Time.now.wday + day_add
      first_week = (Time.now + 1.day).strftime('%V').to_i
    end
    first_week = (first_week > 53 ? first_week % 53 : first_week)
    second_week = ((first_week + 1) > 53 ? (first_week + 1) % 53 : first_week + 1)
    third_week = ((first_week + 2) > 53 ? (first_week + 2) % 53 : first_week + 2)
    rem_days = [1, 2, 3, 4, 5, 6, 7, 8]
    rem_days.shift(first_day)
    sql1 = DeliverySlot.joins("LEFT OUTER JOIN orders ON orders.delivery_slot_id = delivery_slots.id AND status_id NOT IN (-1, 4) AND extract(year from estimated_delivery_at) =  #{Time.now.strftime('%Y')} and extract(week from estimated_delivery_at  + '1 day'::interval) = #{first_week} ").joins('LEFT OUTER JOIN order_positions ON order_positions.order_id = orders.id')
                       .where("delivery_slots.retailer_id = #{retailer_id}")
                       .where("delivery_slots.start > #{start_time + skip_time} AND delivery_slots.day = #{first_day} OR delivery_slots.day in (#{rem_days.join(',')}) ").select("delivery_slots.*, coalesce(sum(order_positions.amount),0) AS total_products, count(distinct orders.id) AS total_orders, #{first_week} as week ").group('delivery_slots.id')
                       .having("delivery_slots.retailer_service_id = 2 AND delivery_slots.is_active = 't' AND (delivery_slots.orders_limit = 0 OR delivery_slots.orders_limit > count(distinct orders.id)) AND (delivery_slots.products_limit = 0 OR (delivery_slots.products_limit > coalesce(sum(order_positions.amount),0) AND (((coalesce(sum(order_positions.amount),0)/(delivery_slots.products_limit * 1.0 )) <= 0.7) OR delivery_slots.products_limit + delivery_slots.products_limit_margin >= coalesce(sum(order_positions.amount),0) + #{items_count})))")
                       .order('delivery_slots.day', 'delivery_slots.start').to_sql
    sql2 = DeliverySlot.joins("LEFT OUTER JOIN orders ON orders.delivery_slot_id = delivery_slots.id AND status_id NOT IN (-1, 4) AND extract(year from estimated_delivery_at) =  #{Time.now.strftime('%Y')} and extract(week from estimated_delivery_at  + '1 day'::interval) = #{second_week} ").joins('LEFT OUTER JOIN order_positions ON order_positions.order_id = orders.id')
                       .where("delivery_slots.retailer_id = #{retailer_id}").select("delivery_slots.*, coalesce(sum(order_positions.amount),0) AS total_products, count(distinct orders.id) AS total_orders, #{second_week} as week ").group('delivery_slots.id')
                       .having("delivery_slots.retailer_service_id = 2 AND delivery_slots.is_active = 't' AND (delivery_slots.orders_limit = 0 OR delivery_slots.orders_limit > count(distinct orders.id)) AND (delivery_slots.products_limit = 0 OR (delivery_slots.products_limit > coalesce(sum(order_positions.amount),0) AND (((coalesce(sum(order_positions.amount),0)/(delivery_slots.products_limit * 1.0 )) <= 0.7) OR delivery_slots.products_limit + delivery_slots.products_limit_margin >= coalesce(sum(order_positions.amount),0) + #{items_count})))")
                       .order('delivery_slots.day', 'delivery_slots.start').to_sql
    sql3 = DeliverySlot.joins("LEFT OUTER JOIN orders ON orders.delivery_slot_id = delivery_slots.id AND status_id NOT IN (-1, 4) AND extract(year from estimated_delivery_at) =  #{Time.now.strftime('%Y')} and extract(week from estimated_delivery_at  + '1 day'::interval) = #{third_week} ").joins('LEFT OUTER JOIN order_positions ON order_positions.order_id = orders.id')
                       .where("delivery_slots.retailer_id = #{retailer_id}").select("delivery_slots.*, coalesce(sum(order_positions.amount),0) AS total_products, count(distinct orders.id) AS total_orders, #{third_week} as week ").group('delivery_slots.id')
                       .having("delivery_slots.retailer_service_id = 2 AND delivery_slots.is_active = 't' AND (delivery_slots.orders_limit = 0 OR delivery_slots.orders_limit > count(distinct orders.id)) AND (delivery_slots.products_limit = 0 OR (delivery_slots.products_limit > coalesce(sum(order_positions.amount),0) AND (((coalesce(sum(order_positions.amount),0)/(delivery_slots.products_limit * 1.0 )) <= 0.7) OR delivery_slots.products_limit + delivery_slots.products_limit_margin >= coalesce(sum(order_positions.amount),0) + #{items_count})))")
                       .order('delivery_slots.day', 'delivery_slots.start').to_sql
    delivery_slots = DeliverySlot.find_by_sql("(#{sql1}) UNION ALL (#{sql2}) UNION ALL (#{sql3}) LIMIT #{for_checkout ? 36 : 1 }")
    delivery_slots
  end

  def self.slots_for_six_days(retailer_id, retailer_delivery_zone_id, skip_time, day_add, items_count = 0, skip_next = false, start_time = Time.now.seconds_since_midnight)
    first_day = Time.now.wday + day_add > 7 ? Time.now.wday + day_add - 7 : Time.now.wday + day_add
    second_day = (first_day + 1) > 7 ? (first_day + 1) - 7 : (first_day + 1)
    third_day = (second_day + 1) > 7 ? (second_day + 1) - 7 : (second_day + 1)
    fourth_day = (third_day + 1) > 7 ? (third_day + 1) - 7 : (third_day + 1)
    fifth_day = (fourth_day + 1) > 7 ? (fourth_day + 1) - 7 : (fourth_day + 1)
    sixth_day = (fifth_day + 1) > 7 ? (fifth_day + 1) - 7 : (fifth_day + 1)
    slot_sort = (first_day == 7) ? 'DESC' : 'ASC'
    DeliverySlot.joins("join (SELECT SUM(products_limit)*MIN(products_limit)/GREATEST(MIN(products_limit),1) total_limit, SUM(products_limit_margin) total_margin, SUM(orders_limit)*MIN(orders_limit)/GREATEST(MIN(orders_limit),1) total_orders_limit, start dsstart, day dsday FROM delivery_slots, retailer_delivery_zones sub_rdz WHERE retailer_delivery_zone_id = sub_rdz.id AND sub_rdz.retailer_id = #{retailer_id} AND day in (#{first_day}, #{second_day}, #{third_day}, #{fourth_day}, #{fifth_day}, #{sixth_day}) AND delivery_slots.is_active = 't' group by start, day) AS totals on totals.dsstart = delivery_slots.start and totals.dsday = delivery_slots.day")
                .joins('join delivery_slots ds on ds.start = delivery_slots.start and ds.day = delivery_slots.day').joins("join retailer_delivery_zones rdz on rdz.id = ds.retailer_delivery_zone_id and rdz.retailer_id = #{retailer_id}")
                .joins("left outer join orders on orders.delivery_slot_id = ds.id and status_id != 4 and date(estimated_delivery_at) >= '#{Time.now.to_date}'").joins('left outer join order_positions on order_positions.order_id = orders.id')
                .where(retailer_delivery_zone_id: retailer_delivery_zone_id).where(" delivery_slots.is_active = 't' AND delivery_slots.start > #{start_time + skip_time} AND delivery_slots.day = #{first_day} OR delivery_slots.day in (#{second_day}, #{third_day}, #{fourth_day}, #{fifth_day}, #{sixth_day})").select('delivery_slots.*, coalesce(sum(order_positions.amount),0) AS total_products, totals.total_limit, totals.total_margin, count(distinct orders.id) AS total_orders, totals.total_orders_limit').group('delivery_slots.id, totals.total_limit, totals.total_margin, totals.total_orders_limit')
                .having("delivery_slots.is_active = 't' and (totals.total_orders_limit = 0 or totals.total_orders_limit > count(distinct orders.id)) and (totals.total_limit = 0 or (totals.total_limit > coalesce(sum(order_positions.amount),0) and (((coalesce(sum(order_positions.amount),0)/(totals.total_limit * 1.0 )) <= 0.7) or totals.total_limit + totals.total_margin >= coalesce(sum(order_positions.amount),0) + #{items_count})))")
                .order("delivery_slots.day #{slot_sort}", 'delivery_slots.start')
  end

  def self.get_slot_info(delivery_slot_id, retailer_id, estimated_delivery_at)
    DeliverySlot.joins("join (SELECT SUM(products_limit)*MIN(products_limit)/GREATEST(MIN(products_limit),1) total_limit, SUM(products_limit_margin) total_margin, SUM(orders_limit)*MIN(orders_limit)/GREATEST(MIN(orders_limit),1) total_orders_limit, start dsstart, day dsday FROM delivery_slots, retailer_delivery_zones sub_rdz WHERE retailer_delivery_zone_id = sub_rdz.id AND sub_rdz.retailer_id = #{retailer_id} group by start, day) AS totals on totals.dsstart = delivery_slots.start and totals.dsday = delivery_slots.day")
                .joins('join delivery_slots ds on ds.start = delivery_slots.start and ds.day = delivery_slots.day').joins("join retailer_delivery_zones rdz on rdz.id = ds.retailer_delivery_zone_id and rdz.retailer_id = #{retailer_id}")
                .joins("left outer join orders on orders.delivery_slot_id = ds.id and status_id not in (-1, 4) and date(estimated_delivery_at) = '#{estimated_delivery_at}'").joins('left outer join order_positions on order_positions.order_id = orders.id')
                .where(id: delivery_slot_id).select('delivery_slots.*, coalesce(sum(order_positions.amount),0) AS total_products, totals.total_limit, totals.total_margin, count(distinct orders.id) AS total_orders, totals.total_orders_limit').group('delivery_slots.id, totals.total_limit, totals.total_margin, totals.total_orders_limit').first
  end

  def self.get_cc_slot_info(delivery_slot_id, estimated_delivery_at)
    DeliverySlot.joins("left outer join orders on orders.delivery_slot_id = delivery_slots.id and status_id not in (-1, 4) and date(estimated_delivery_at) = '#{estimated_delivery_at}'").joins('left outer join order_positions on order_positions.order_id = orders.id')
                .where(id: delivery_slot_id).select('delivery_slots.*, coalesce(sum(order_positions.amount),0) AS total_products, count(distinct orders.id) AS total_orders').group('delivery_slots.id').first
  end
end

class AvailableSlot < DeliverySlot
  self.table_name = 'available_slots_mv'

  def readonly?
    true
  end

  def self.refresh
    ActiveRecord::Base.connection.execute('REFRESH MATERIALIZED VIEW CONCURRENTLY retailer_available_slots_mv;')
    ActiveRecord::Base.connection.execute("SET TIME ZONE '#{ENV['TZ']}';REFRESH MATERIALIZED VIEW CONCURRENTLY available_slots_mv;")
  end

  def self.refresh_capacity
    ActiveRecord::Base.connection.execute("SET TIME ZONE '#{ENV['TZ']}';REFRESH MATERIALIZED VIEW delivery_slots_capacity_mv;")
  end
end

# This class is Mapping Retailer Slots view to get the next available delivery slots
class RetailerAvailableSlot < DeliverySlot
  self.table_name = 'retailer_available_slots'

  def readonly?
    true
  end

end

# This class only return next 1 available slot for the retailer's selected zone from materialized view
class RetailerNextAvailableSlot < DeliverySlot
  self.table_name = 'retailer_available_slots_mv'

  def readonly?
    true
  end

end

# class NextAvailableSlot < DeliverySlot
#   self.table_name = "next_available_slots"
# end
