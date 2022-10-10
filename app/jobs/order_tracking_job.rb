class  OrderTrackingJob
  @queue = :order_tracking_queue

  def self.perform
    
    order_tracking_config = SystemConfiguration.where("key ilike '%order_tracking%'").select(:id,:key,:value)
    
    job_interval = order_tracking_config.select{|s| s.key == 'order_tracking.job_interval'}.first.try(:value).to_i
    not_accepted = order_tracking_config.select{|s| s.key == 'order_tracking.not_accepted'}.first.try(:value).to_s
    not_accepted_before_time = not_accepted.split(':')[0].split('-').map{|i| i.to_i}.sort
    not_accepted_after_time = not_accepted.split(':')[1].split('-').map{|i| i.to_i}.sort
    not_ready_to_deliver = order_tracking_config.select{|s| s.key == 'order_tracking.not_ready_to_deliver'}.first.try(:value).to_s
    not_ready_to_deliver = not_ready_to_deliver.split('-').map{|i| i.to_i}.sort
    not_enrouted = order_tracking_config.select{|s| s.key == 'order_tracking.not_enrouted'}.first.try(:value).to_s
    not_enrouted = not_enrouted.split('-').map{|i| i.to_i}.sort

    pend_time_diffs = not_accepted_before_time.map{|t| "extract('epoch' from orders.estimated_delivery_at - '#{Time.now.utc}')/60 between #{t} - #{job_interval}/2.0 and #{t} + #{job_interval}/2.0 " }
    pend_time_diffs = pend_time_diffs + not_accepted_after_time.map{|t| "extract('epoch' from '#{Time.now.utc}' - orders.estimated_delivery_at)/60 between #{t} - #{job_interval}/2.0 and #{t} + #{job_interval}/2.0 " }
    pending_orders = Order.where("orders.status_id = 0 and (#{pend_time_diffs.join(' or ')})")
    pending_orders = pending_orders.select("orders.id, orders.status_id, orders.estimated_delivery_at, extract('epoch' from '#{Time.now.utc}' - orders.estimated_delivery_at)/60 as before_after")

    pending_orders.each do |order|
      t = order.before_after.to_i.abs
      if order.before_after < 0
        t = not_accepted_before_time.min_by{|x| (t-x).abs}
        Slack::SlackNotification.new.send_pending_order_before_notification(order.id, t)
      else
        t = not_accepted_after_time.min_by{|x| (t-x).abs}
        Slack::SlackNotification.new.send_pending_order_after_notification(order.id, t)
      end
      sleep(1)
    end

    accept_time_diffs = not_ready_to_deliver.map{|t| "extract('epoch' from '#{Time.now.utc}' - orders.estimated_delivery_at)/60 between #{t} - #{job_interval}/2.0 and #{t} + #{job_interval}/2.0 " }
    accepted_orders = Order.where("orders.status_id = 1 and (#{accept_time_diffs.join(' or ')})")
    accepted_orders = accepted_orders.select("orders.id, orders.status_id, orders.estimated_delivery_at, extract('epoch' from '#{Time.now.utc}' - orders.estimated_delivery_at)/60 as accepted_time")

    accepted_orders.each do |order|
      t = order.accepted_time.to_i.abs      
      t = not_ready_to_deliver.min_by{|x| (t-x).abs}
      Slack::SlackNotification.new.send_accepted_order_after_notification(order.id, t)
      sleep(1)
    end

    ready_order_time_diffs = not_enrouted.map{|t| "extract('epoch' from '#{Time.now.utc}' - orders.estimated_delivery_at)/60 between #{t} - #{job_interval}/2.0 and #{t} + #{job_interval}/2.0 " }
    ready_orders = Order.where("orders.status_id = 11 and (#{ready_order_time_diffs.join(' or ')})")
    ready_orders = ready_orders.select("orders.id, orders.status_id, orders.estimated_delivery_at, extract('epoch' from '#{Time.now.utc}' - orders.estimated_delivery_at)/60 as ready_time")

    ready_orders.each do |order|
      t = order.ready_time.to_i.abs      
      t = not_enrouted.min_by{|x| (t-x).abs}
      Slack::SlackNotification.new.send_ready_order_after_notification(order.id, t)
      sleep(1)
    end

  end
end