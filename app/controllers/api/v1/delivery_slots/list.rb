class API::V1::DeliverySlots::List < Grape::API
  version 'v1', using: :path
  format :json

  resource :delivery_slots do
    desc 'Delivery Slots for multiple retailers'

    params do
      optional :retailer_ids, type: String, desc: 'Retailer_ids comma separated', documentation: {example: "16,178,210"}
      optional :retailer_delivery_zone_ids, type: String, desc: 'Retailer Delivery zone ids', documentation: { example: "210,1361" }
      optional :latitude, type: Float, desc: 'Latitude of the shopper', documentation: { example: 24.887565687 }
      optional :longitude, type: Float, desc: 'Longitude of shopper', documentation: { example: 55.6672678687 }
    end

    get '/list' do
      #TODO: For Multiple Retailers Have To find Optimized Way
      point  = "POINT (#{params[:longitude]} #{params[:latitude]})"
      wday = Time.now.wday + 1
      first_week = (Time.now + 1.day).strftime('%V').to_i
      sql1 = DeliverySlot.joins("JOIN retailer_delivery_zones ON retailer_delivery_zones.id  = delivery_slots.retailer_delivery_zone_id").joins("JOIN delivery_zones ON delivery_zones.id = retailer_delivery_zones.delivery_zone_id").where("ST_Contains(delivery_zones.coordinates, ST_GeomFromText(?)) = 't'", point).joins("JOIN retailers ON retailers.id = delivery_slots.retailer_id").where("delivery_slots.retailer_id in (#{params[:retailer_ids]}) and (IF retailers.cutoff_time > 0 THEN (day = #{wday} + 1 AND start > (0 + retailers.delivery_slot_skip_hours) OR day > #{wday} + 1) ELSIF #{Time.now.seconds_since_midnight} > retailers.cutoff_time THEN (day = #{wday} + 2 AND start > (0 + retailers.delivery_slot_skip_hours) OR day > #{wday} + 2) ELSE start > #{Time.now.seconds_since_midnight} + retailers.delivery_slot_skip_hours AND day = #{wday} OR day > #{wday} END IF) and day = #{wday} or day > #{wday}").where(is_active: true)
          .joins("join (SELECT SUM(products_limit)*MIN(products_limit)/GREATEST(MIN(products_limit),1) total_limit, SUM(products_limit_margin) total_margin, SUM(orders_limit)*MIN(orders_limit)/GREATEST(MIN(orders_limit),1) total_orders_limit, start dsstart, day dsday, retailer_id dsretailer_id FROM delivery_slots WHERE delivery_slots.retailer_id in (#{params[:retailer_ids]}) AND delivery_slots.is_active = 't' group by start, day, retailer_id) AS totals on totals.dsstart = delivery_slots.start and totals.dsday = delivery_slots.day and totals.dsretailer_id = delivery_slots.retailer_id")
          .joins("left outer join orders on orders.delivery_slot_id = delivery_slots.id and status_id != 4 and extract(year from estimated_delivery_at) =  #{Time.now.strftime('%Y')} and extract(week from estimated_delivery_at  + '1 day'::interval) = #{first_week} ").joins("left outer join order_positions on order_positions.order_id = orders.id")
          .select("delivery_slots.start, delivery_slots.end, delivery_slots.day,  #{first_week} as week, array_agg(delivery_slots.retailer_id) ").group("delivery_slots.start, delivery_slots.end, delivery_slots.day, delivery_slots.is_active, totals.total_limit, totals.total_margin, totals.total_orders_limit")
          .having("delivery_slots.is_active = 't' and (totals.total_orders_limit = 0 or totals.total_orders_limit > count(distinct orders.id)) and (totals.total_limit = 0 or (totals.total_limit > coalesce(sum(order_positions.amount),0) and (((coalesce(sum(order_positions.amount),0)/(totals.total_limit * 1.0 )) <= 0.7) or totals.total_limit + totals.total_margin >= coalesce(sum(order_positions.amount),0) + #{0})))")
          .order("delivery_slots.day","delivery_slots.start").to_sql
      sql2 = DeliverySlot.joins("JOIN retailer_delivery_zones ON retailer_delivery_zones.id  = delivery_slots.retailer_delivery_zone_id").joins("JOIN delivery_zones ON delivery_zones.id = retailer_delivery_zones.delivery_zone_id").where("ST_Contains(delivery_zones.coordinates, ST_GeomFromText(?)) = 't'", point).where("delivery_slots.retailer_id in (#{params[:retailer_ids]})").where(is_active: true)
          .joins("join (SELECT SUM(products_limit)*MIN(products_limit)/GREATEST(MIN(products_limit),1) total_limit, SUM(products_limit_margin) total_margin, SUM(orders_limit)*MIN(orders_limit)/GREATEST(MIN(orders_limit),1) total_orders_limit, start dsstart, day dsday, retailer_id dsretailer_id FROM delivery_slots WHERE delivery_slots.retailer_id in (#{params[:retailer_ids]}) AND delivery_slots.is_active = 't' group by start, day, retailer_id) AS totals on totals.dsstart = delivery_slots.start and totals.dsday = delivery_slots.day and totals.dsretailer_id = delivery_slots.retailer_id")
          .joins("left outer join orders on orders.delivery_slot_id = delivery_slots.id and status_id != 4 and extract(year from estimated_delivery_at) =  #{Time.now.strftime('%Y')} and extract(week from estimated_delivery_at  + '1 day'::interval) = #{first_week + 1} ").joins("left outer join order_positions on order_positions.order_id = orders.id")
          .select("delivery_slots.start, delivery_slots.end, delivery_slots.day,  #{first_week + 1} as week, array_agg(delivery_slots.retailer_id) ").group("delivery_slots.start, delivery_slots.end, delivery_slots.day, delivery_slots.is_active, totals.total_limit, totals.total_margin, totals.total_orders_limit")
          .having("delivery_slots.is_active = 't' and (totals.total_orders_limit = 0 or totals.total_orders_limit > count(distinct orders.id)) and (totals.total_limit = 0 or (totals.total_limit > coalesce(sum(order_positions.amount),0) and (((coalesce(sum(order_positions.amount),0)/(totals.total_limit * 1.0 )) <= 0.7) or totals.total_limit + totals.total_margin >= coalesce(sum(order_positions.amount),0) + #{0})))")
          .order("delivery_slots.day","delivery_slots.start").to_sql
      sql3 = DeliverySlot.joins("JOIN retailer_delivery_zones ON retailer_delivery_zones.id  = delivery_slots.retailer_delivery_zone_id").joins("JOIN delivery_zones ON delivery_zones.id = retailer_delivery_zones.delivery_zone_id").where("ST_Contains(delivery_zones.coordinates, ST_GeomFromText(?)) = 't'", point).where("delivery_slots.retailer_id in (#{params[:retailer_ids]})").where(is_active: true)
          .joins("join (SELECT SUM(products_limit)*MIN(products_limit)/GREATEST(MIN(products_limit),1) total_limit, SUM(products_limit_margin) total_margin, SUM(orders_limit)*MIN(orders_limit)/GREATEST(MIN(orders_limit),1) total_orders_limit, start dsstart, day dsday, retailer_id dsretailer_id FROM delivery_slots WHERE delivery_slots.retailer_id in (#{params[:retailer_ids]}) AND delivery_slots.is_active = 't' group by start, day, retailer_id) AS totals on totals.dsstart = delivery_slots.start and totals.dsday = delivery_slots.day and totals.dsretailer_id = delivery_slots.retailer_id")
          .joins("left outer join orders on orders.delivery_slot_id = delivery_slots.id and status_id != 4 and extract(year from estimated_delivery_at) =  #{Time.now.strftime('%Y')} and extract(week from estimated_delivery_at  + '1 day'::interval) = #{first_week + 2} ").joins("left outer join order_positions on order_positions.order_id = orders.id")
          .select("delivery_slots.start, delivery_slots.end, delivery_slots.day,  #{first_week + 2} as week, array_agg(delivery_slots.retailer_id) ").group("delivery_slots.start, delivery_slots.end, delivery_slots.day, delivery_slots.is_active, totals.total_limit, totals.total_margin, totals.total_orders_limit")
          .having("delivery_slots.is_active = 't' and (totals.total_orders_limit = 0 or totals.total_orders_limit > count(distinct orders.id)) and (totals.total_limit = 0 or (totals.total_limit > coalesce(sum(order_positions.amount),0) and (((coalesce(sum(order_positions.amount),0)/(totals.total_limit * 1.0 )) <= 0.7) or totals.total_limit + totals.total_margin >= coalesce(sum(order_positions.amount),0) + #{0})))")
          .order("delivery_slots.day","delivery_slots.start").to_sql
      # DeliverySlot.find_by_sql("(#{sql1}) UNION ALL (#{sql2}) UNION ALL (#{sql3}) LIMIT 36")
      DeliverySlot.find_by_sql("(#{sql1})")
    end
  end
end
