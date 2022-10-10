class Orders::ShopperCancelOrder < Orders::Base

  integer :order_id
  integer :shopper_id
  string :message, default: nil
  string :suggestion, default: nil
  integer :reason, default: nil

  validate :shopper_has_order
  validate :status_is_pending
  # validate :order_is_old

  def execute
    result_order = cancel_order!
    retailer.cancel_order_notify(order_id)
    order.shopper.cancel_order_notify(order, I18n.t('message.reason'), order.retailer_company_name)
    improvement
    result_order
  end

  private

  def order
    @order ||= Order.find_by(id: order_id)
  end

  def retailer
    @retailer ||= Retailer.find_by(id: order.retailer_id)
  end

  def set_message
    if reason.present?
      JSON(SystemConfiguration.find_by(key: 'order_cancel').value)[reason.to_s]['en']
    else
      # message.blank? ? 'your request' : message # || I18n.t('cancel', scope: 'activerecord.messages.order')
      message.blank? ? I18n.t('message.reason') : message # || I18n.t('cancel', scope: 'activerecord.messages.order')
    end
  end

  def cancel_order!
    order.update(status_id: 4, canceled_at: Time.new, user_canceled_type: 2, message: set_message)
    order.save
    order
  end

  def improvement
    return if suggestion.blank?

    order = OrdersDatum.find_or_initialize_by(order_id: order_id)
    order.detail[:suggestion] = suggestion
    order.save!
  end

end
