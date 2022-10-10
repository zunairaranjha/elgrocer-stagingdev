# frozen_string_literal: true

class Slack::SlackNotification
  # Initialize the object with a slack webhook uri
  def initialize
    I18n.locale = :en
    @notifier = Slack::Notifier.new Rails.application.config.slack_hook
  end

  def send_new_order_notification(order_id)
    order = get_order(order_id)
    @notifier.ping prepare_text_for_order_notification(order_id), channel: '#giftcardstore' if SystemConfiguration.get_key_value('slack:giftcardstore-ids').to_s.scan(/\d+/).include? order.retailer_id.to_s
    @notifier.ping prepare_text_for_order_notification(order_id) # if Rails.env.production?
  end

  def send_after_order_notification(order_id)
    @notifier.ping prepare_text_for_after_order_notification(order_id), channel: '#order-tracking' # if Rails.env.production?
  end

  def send_after_order_feedback_notification(order_id)
    order_feedback = OrderFeedback.find_by(order_id: order_id)
    # @notifier.ping prepare_text_for_after_order_feedback_notification(order_id), channel: "#order-tracking" #if Rails.env.production?
    @notifier.ping prepare_text_for_after_order_feedback_notification(order_id), channel: '#order-reviews' if order_feedback.delivery.to_i.between?(1, 3) || !order_feedback.comments.nil?
  end

  def send_retailer_status_change_notification(retailer_id, source)
    @notifier.ping prepare_text_for_retailer_status_change_notification(retailer_id, source), channel: '#stores-notifications' # if Rails.env.production?
  end

  def send_pending_order_before_notification(order_id, time)
    @notifier.ping prepare_text_for_pending_order_before_notification(order_id, time), channel: '#order-tracking-not-accepted' # if Rails.env.production?
  end

  def send_pending_order_after_notification(order_id, time)
    @notifier.ping prepare_text_for_pending_order_after_notification(order_id, time), channel: '#order-tracking-not-accepted'
  end

  def send_checkout_order_notification(order_id)
    @notifier.ping prepare_text_for_checkout_order_notification(order_id), channel: '#order-tracking-ready-for-checkout'
  end

  def send_accepted_order_after_notification(order_id, time)
    @notifier.ping prepare_text_for_accepted_order_after_notification(order_id, time), channel: '#order-tracking-not-ready-to-deliver'
  end

  def send_ready_order_after_notification(order_id, time)
    @notifier.ping prepare_text_for_ready_order_after_notification(order_id, time), channel: '#order-tracking-not-enroute'
    # , channel: "#order-tracking" #if Rails.env.production?
  end

  def send_order_not_assigned_notification(order_id, team)
    channel_postfix = team.to_s =~ /dubai/i ? 'dubai' : 'other'
    @notifier.ping prepare_text_for_order_not_assigned(order_id, team), channel: "#order-tracking-not-assigned-#{channel_postfix}"
  end

  def send_fraud_notification(shopper)
    @notifier.ping prepare_text_for_fraud_notification(shopper), channel: '#shopper-tracking'
  end

  def send_partial_refund_notification(order, params)
    @notifier.ping prepare_text_for_refund_notification(order, params), channel: '#orders-refund-notifications'
  end
  private

  def get_order(order_id)
    @order ||= Order.find(order_id)
  end

  def prepare_text_for_order_notification(order_id)
    order = get_order(order_id)
    order_number = order_id
    order_company_name = order.retailer_company_name
    order_created_at = order.created_at
    order_type = order.delivery_slot_id.to_i.positive? ? order.schedule_for : 'ASAP'
    "#{order_company_name} has received an order!\nNumber: #{order_number}\nTimestamp: #{order_created_at}\nScheduled for: #{order_type}"
  end

  def prepare_text_for_after_order_notification(order_id)
    order = get_order(order_id)
    order_number = order_id
    order_company_name = order.retailer_company_name
    order_created_at = order.delivery_slot_id.to_i.positive? ? order.estimated_delivery_at : order.created_at
    duration = (Time.now - order_created_at).round / 1.minutes
    nex_status_id = order.status_id.to_i + 1
    nex_status = order.statuses_array[nex_status_id][:name]
    shopper_address = "#{order.shopper_address_apartment_number},#{order.shopper_address_building_name},#{order.shopper_address_street},#{order.shopper_address_area}"
    order_type = order.delivery_slot_id.to_i.positive? ? order.schedule_for : 'ASAP'
    # Requeue notifiction
    #::SlackNotificationJob.set(wait_until: 10.minutes.from_now).perform_later(order_id, nex_status_id)

    # days_remaining = (wallet.expire_date - DateTime.now).round/1.day
    # "Order (#{order_number}:#{order_company_name}:#{order_created_at}:#{order.status}) is not #{nex_status} after #{duration} minutes"
    order_path = "https://el-grocer-#{Rails.env.production? ? 'admin' : 'staging-dev'}.herokuapp.com/admin/orders/#{order_id}"
    "Order (#{order_number}) is not #{nex_status} after #{duration} minutes\nStore Name: #{order_company_name}\nStore Phone: #{order.retailer_phone_number}\nShopper Name: #{order.shopper_name}\nShopper Email: #{order.shopper.email}\nTimestamp: #{order_created_at}\nDelivery Address: #{shopper_address}\nScheduled for: #{order_type}\n#{order_path}"
  end

  def prepare_text_for_after_order_feedback_notification(order_id)
    order = get_order(order_id)
    order_number = order_id
    order_company_name = order.retailer_company_name
    # order_created_at = order.created_at
    order_type = order.delivery_slot_id.to_i.positive? ? order.schedule_for : 'ASAP'
    # order_path = "#{ENV['RAILS_SERVE_ASSETS_HOST']}/admin/orders/#{order.id}"
    feedback = order.order_feedback
    order_path = "https://el-grocer-#{Rails.env.production? ? 'admin' : 'staging-dev'}.herokuapp.com/admin/orders/#{order_id}"
    "Order (#{order_number}) has feedback\nStore Name: #{order_company_name}\nDelivery(*): #{feedback&.delivery_stars}\nOn time: #{feedback&.speed}\nAccuracy: #{feedback&.accuracy}\nPrice: #{feedback&.price}\nComments: #{feedback&.comments}\nScheduled for: #{order_type}\n#{order_path}"
  end

  def prepare_text_for_retailer_status_change_notification(retailer_id, source)
    retailer = Retailer.find(retailer_id)
    retailer_path = "https://el-grocer-#{Rails.env.production? ? 'admin' : 'staging-dev'}.herokuapp.com/admin/retailers/#{retailer_id}"
    "Store Name: #{retailer.company_name}\nStore Phone: #{retailer.phone_number}\nStore Email: #{retailer.contact_email}\n#{retailer.is_opened ? 'Opened' : 'Closed'} Timing: #{retailer.updated_at}\nSource: #{source}\n#{retailer_path}"
  end

  def prepare_text_for_pending_order_before_notification(order_id, time)
    params = message_params(order_id, time)
    "Order (#{params[:order_number]}) is in Pending ( #{params[:order_time]} mins for Delivery time)\nStore Name: #{params[:order_company_name]}\nStore Phone: #{params[:order_retailer_phone]}\nShopper Name: #{params[:shopper_name]}\nShopper Email: #{params[:shopper_email]}\nShopper Contact: #{params[:shopper_phone_number]}\nScheduled for: #{params[:order_type]}\n#{params[:order_path]}"
  end

  def prepare_text_for_pending_order_after_notification(order_id, time)
    params = message_params(order_id, time)
    "Order (#{params[:order_number]}) is not accepted after #{params[:order_time]} mins\nStore Name: #{params[:order_company_name]}\nStore Phone: #{params[:order_retailer_phone]}\nShopper Name: #{params[:shopper_name]}\nShopper Email: #{params[:shopper_email]}\nShopper Contact: #{params[:shopper_phone_number]}\nScheduled for: #{params[:order_type]}\n#{params[:order_path]}"
  end

  def prepare_text_for_checkout_order_notification(order_id)
    params = message_params(order_id)
    "Order (#{params[:order_number]}) is Ready for Checkout\nStore Name: #{params[:order_company_name]}\nStore Phone: #{params[:order_retailer_phone]}\nShopper Name: #{params[:shopper_name]}\nShopper Email: #{params[:shopper_email]}\nShopper Contact: #{params[:shopper_phone_number]}\nScheduled for: #{params[:order_type]}\n#{params[:order_path]}"
  end

  def prepare_text_for_accepted_order_after_notification(order_id, time)
    params = message_params(order_id, time)
    "Order (#{params[:order_number]}) is not Ready to Deliver after #{params[:order_time]} mins\nStore Name: #{params[:order_company_name]}\nStore Phone: #{params[:order_retailer_phone]}\nShopper Name: #{params[:shopper_name]}\nShopper Email: #{params[:shopper_email]}\nShopper Contact: #{params[:shopper_phone_number]}\nScheduled for: #{params[:order_type]}\n#{params[:order_path]}"
  end

  def prepare_text_for_ready_order_after_notification(order_id, time)
    params = message_params(order_id, time)
    "Order (#{params[:order_number]}) is not enroute after #{params[:order_time]} mins\nStore Name: #{params[:order_company_name]}\nStore Phone: #{params[:order_retailer_phone]}\nShopper Name: #{params[:shopper_name]}\nShopper Email: #{params[:shopper_email]}\nShopper Contact: #{params[:shopper_phone_number]}\nScheduled for: #{params[:order_type]}\n#{params[:order_path]}"
  end

  def prepare_text_for_order_not_assigned(order_id, team)
    params = message_params(order_id)
    "Order (#{params[:order_number]}) is not assigned\nTeam: #{team}\nStore Name: #{params[:order_company_name]}\nStore Phone: #{params[:order_retailer_phone]}\nShopper Name: #{params[:shopper_name]}\nShopper Email: #{params[:shopper_email]}\nShopper Contact: #{params[:shopper_phone_number]}\nScheduled for: #{params[:order_type]}\n#{params[:order_path]}"
  end

  def prepare_json_for_order_notification(text)
    {
      'text': text
    }
  end

  def prepare_text_for_fraud_notification(shopper)
    "Online payment of the following shopper has been blocked due to potential Credit Card Check\nShopper Id: #{shopper.id}\nShopper Name: #{shopper.name}\nShopper Email: #{shopper.email}\nShopper Phone: #{shopper.phone_number}"
  end

  def prepare_text_for_refund_notification(order, params)
    opl = OnlinePaymentLog.select(:id, :details).find_by(order_id: order.id, fort_id: params[:pspReference])
    msg = "A Refund has occurred\nOrder: #{order.id}\nOriginal Amount: #{(order.final_amount.to_f * 100).to_i - order.refunded_amount.to_i} cents\nRefunded Amount: #{params[:amount][:value].to_i} cents"
    msg += "\nAdmin User: #{opl.details['owner_email']}" if opl
    msg
  end

  def message_params(order_id, time = nil)
    order = get_order(order_id)
    params = {
      order_number: order_id,
      order_company_name: order.retailer_company_name,
      order_retailer_phone: order.retailer_phone_number,
      shopper_name: order.shopper_name,
      shopper_email: order.shopper.email,
      shopper_phone_number: order.shopper_phone_number,
      order_type: order.delivery_slot_id.to_i.positive? ? order.schedule_for : 'ASAP',
      order_path: "https://el-grocer-#{Rails.env.production? ? 'admin' : 'staging-dev'}.herokuapp.com/admin/orders/#{order_id}"
    }
    params[:order_time] = time unless time.nil?
    params
  end

end
