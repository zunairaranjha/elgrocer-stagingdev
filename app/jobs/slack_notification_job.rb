class SlackNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(order_id, status_id = 0)
    Slack::SlackNotification.new.send_new_order_notification(order_id) if status_id == 0
    # Send order feedback slack
    Slack::SlackNotification.new.send_after_order_feedback_notification(order_id) if status_id == 12

    # settings = Setting.take
    settings = Setting.select(:id, :order_accept_duration, :order_enroute_duration, :order_delivered_duration).first
    order = get_order(order_id)
    # Kafka::CloudKarafka.new.produce_kafka_msg(order)
    if settings && order
      if status_id == -2 and order.status_id == -1
        order.shopper.pending_payment_notify(order)
      elsif status_id == -1 and order.status_id == -1
        I18n.locale = order.language.to_sym
        order.update(status_id: 4, updated_at: Time.now, message: I18n.t("message.payment_failure"), user_canceled_type: 5)
        order.shopper.cancel_payment_failure(order)
      end
      # accept_duration = settings.order_accept_duration.to_i || 2
      # enroute_duration = settings.order_enroute_duration.to_i || 30 #- accept_duration
      # deliver_duration = settings.order_delivered_duration.to_i || 60 #- enroute_duration
      # if order.delivery_slot_id.present?
        # time elapse push notification
        if status_id == 13
          order.retailer.new_order_notify(order.id)
          OrderAllocationJob.perform_later(order)
        end
        # next_day_patch = Time.now.wday + 1 == order.delivery_slot.start ? 0 : 1
        # ::SlackNotificationJob.set(wait_until: (86400 * next_day_patch + order.delivery_slot.start - Time.now.seconds_since_midnight - reminder_hours).seconds.from_now).perform_later(order_id)
       
        if status_id == 0
          # accept_duration = (order.estimated_delivery_at - Time.now + accept_duration.minutes) / 1.minutes
          # enroute_duration = (order.estimated_delivery_at - Time.now + enroute_duration.minutes) / 1.minutes #- accept_duration
          # deliver_duration = (order.estimated_delivery_at - Time.now + deliver_duration.minutes) / 1.minutes #- enroute_duration

          # push notification for time elapse
          reminder_hours = order.retailer.show_pending_order_hours || 1
          time_elapse_minutes = (order.estimated_delivery_at - Time.now - reminder_hours*3600.seconds + 30.seconds) / 1.minutes
          time_elapse_minutes = time_elapse_minutes.to_i > 0 ? time_elapse_minutes : 0.2
          ::SlackNotificationJob.set(wait_until: time_elapse_minutes.minutes.from_now).perform_later(order_id, 13)
        end
      
        # end
      # wait for order online payment detail
      cancellation_duration = ENV['AUTO_CANCEL_DURATION'] || 10
      ::SlackNotificationJob.set(wait_until: cancellation_duration.to_i.minutes.from_now).perform_later(order_id, -1) if status_id == 0
      notify_payment_duration = ENV['PENDING_PAYMENT_NOTIFY_DURATION'] || 5
      ::SlackNotificationJob.set(wait_until: notify_payment_duration.to_i.minutes.from_now).perform_later(order_id, -2) if status_id == 0
      # wait for order accpeted
      # ::SlackNotificationJob.set(wait_until: accept_duration.minutes.from_now).perform_later(order_id, 1) if status_id == 0
      ## reminder after 5 min
      # ::SlackNotificationJob.set(wait_until: (5 + accept_duration).minutes.from_now).perform_later(order_id, 1) if status_id == 0
      ## reminder after 10 min
      # ::SlackNotificationJob.set(wait_until: (10 + accept_duration).minutes.from_now).perform_later(order_id, 1) if status_id == 0
      ## slack notify
      # Slack::SlackNotification.new.send_after_order_notification(order_id) if status_id == 1 && order.status_id == 0

      # wait for order en-routed
      # ::SlackNotificationJob.set(wait_until: enroute_duration.minutes.from_now).perform_later(order_id, 2) if status_id == 0
      # ::SlackNotificationJob.set(wait_until: (5 + enroute_duration).minutes.from_now).perform_later(order_id, 2) if status_id == 0
      # ::SlackNotificationJob.set(wait_until: (10 + enroute_duration).minutes.from_now).perform_later(order_id, 2) if status_id == 0
      # Slack::SlackNotification.new.send_after_order_notification(order_id) if status_id == 2 && order.status_id == 1

      # wait for order delivered/completed
      # ::SlackNotificationJob.set(wait_until: deliver_duration.minutes.from_now).perform_later(order_id, 3) if status_id == 0
      # Slack::SlackNotification.new.send_after_order_notification(order_id) if status_id == 3 && order.status_id == 2
    end
  end

  private

  def get_order(order_id)
    Order.find_by(id: order_id)
  end
end
