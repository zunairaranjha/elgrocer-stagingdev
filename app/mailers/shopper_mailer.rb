class ShopperMailer < ApplicationMailer
  default from: 'elGrocer by Smiles <no-reply@elgrocer.com>'

  def welcome_shopper(shopper_id, longitude = nil, latitude = nil)
    @retailers = Retailer.all_with_zone(longitude, latitude).limit(3) if (longitude.present? && latitude.present?)
    @shopper = Shopper.find(shopper_id)
    I18n.locale = @shopper.language.to_sym
    mail(to: @shopper.email, subject: 'Welcome to elGrocer by Smiles')
    Analytic.add_activity('Welcome Email', @shopper)
  end

  def wallet_used(shopper_id, amount_used)
    @shopper = Shopper.find(shopper_id)
    I18n.locale = @shopper.language.to_sym
    @amount_used = amount_used
    mail(to: @shopper.email, subject: 'Wallet amount used')
  end

  def order_placement(order_id)
    @order = Order.find(order_id)
    @shopper = @order.shopper
    I18n.locale = @order.language.to_sym
    @retailer = @order.retailer
    if @retailer.send_tax_invoice && @order.status_id.positive?
      @inv_no = (Time.now.to_f * 1000).floor
      order_data = OrdersDatum.find_or_initialize_by(order_id: order_id)
      order_data.detail['trn_invoice'] = @inv_no
      order_data.save
    end
    @orders_datum = @order.orders_datum
    # @order_positions = @order.order_positions
    @orderTime = @order.created_at.strftime('%I:%M%p')
    mail(to: @shopper.email, subject: @order.status_id.zero? ? I18n.t('order_placement.thanks_order') : I18n.t('order_placement.subject'))
    Analytic.add_activity('Order Placement', @shopper)

  end

  def new_order_placement(shopper_id)
    @shopper = Shopper.find(shopper_id)
    I18n.locale = @shopper.language.to_sym
    mail(to: @shopper.email, subject: I18n.t('order_placement.thanks_order'))
  end

  def password_reset(shopper_id)
    @shopper = Shopper.find(shopper_id)
    I18n.locale = @shopper.language.to_sym
    mail(to: @shopper.email, subject: 'Password Reset')
  end

  def order_reminder(shopper_id, rule_id)
    @shopper = Shopper.find(shopper_id)
    I18n.locale = @shopper.language.to_sym
    @email_rule = EmailRule.find(rule_id)
    template = @email_rule.promotion_code.present? ? 'reminder_with_promo' : 'reminder_without_promo'
    mail(to: @shopper.email, subject: I18n.t('remainder.subject'), template_name: template)
    Analytic.add_activity("#{@email_rule.name}", @shopper)
  end

  def abandon_basket(shopper_id, rule_id)
    @shopper = Shopper.find(shopper_id)
    @email_rule = EmailRule.find(rule_id)
    mail(to: @shopper.email, subject: 'Your basket is waiting for you!')
    Analytic.add_activity("#{@email_rule.name}", @shopper)
  end

  def substitution(order_id, subs_link)
    @order = Order.find(order_id)
    I18n.locale = @order.language.to_sym
    @substitution_url = subs_link
    mail(to: @order.shopper.email, subject: "elGrocer by Smiles: #{I18n.t("message.substitution")}")
  end

  def delete_account_email(current_shopper)
    @shopper = current_shopper
    I18n.locale = @shopper.language.to_sym
    @body = I18n.t('emails.delete_account_email_hi')
    @body1 = I18n.t('emails.delete_account_email_user_name', shopper_name: @shopper.name)
    @body2 = I18n.t('emails.delete_account_email_body', current_date: Time.now.to_date)
    @body3 = I18n.t('emails.delete_account_email_body_1')
    @body4 = I18n.t('emails.delete_account_email_body_2')
    mail(to: @shopper.email, subject: I18n.t('emails.delete_account_subject'))
  end
end
