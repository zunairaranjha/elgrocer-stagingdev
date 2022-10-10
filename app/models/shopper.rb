# frozen_string_literal: true

class Shopper < ActiveRecord::Base
  include GoogleMessaging
  include AppleNotifications
  # include RegisterNotifications
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable # , :validatable

  # validates :email, presence: true, uniqueness: { case_sensitive: false }
  # validates :password, presence: true, on: :create
  # validate :phone_number_uniqueness
  # validates :referral_code, uniqueness: true
  # validates :password, confirmation: true
  validates :phone_number, format: { with: /\A\+\d{12}\z/ }, unless: :is_deleted

  attr_accessor :block_shopper

  has_many :shopper_addresses
  has_many :orders
  has_many :order_positions, through: :orders
  has_many :order_feedbacks, through: :orders
  has_many :shopper_favourite_retailers
  has_many :shopper_favourite_products
  has_many :favourite_retailers, class_name: 'Retailer', through: :shopper_favourite_retailers, source: :retailer
  has_many :favourite_products, class_name: 'Product', through: :shopper_favourite_products, source: :product
  belongs_to :referrer, optional: true, class_name: 'Shopper', foreign_key: 'referred_by'
  has_many :referrees, -> { order(:name) }, class_name: 'Shopper', foreign_key: 'referred_by'
  has_many :referral_wallets
  has_many :referral_wallet_realizations, through: :referral_wallets
  has_many :credit_cards, dependent: :destroy

  has_many :analytics, as: :owner

  has_many :shopper_cart_products, dependent: :destroy
  has_many :collector_details
  has_many :vehicle_details
  has_many :user_platform_logs
  has_one :shoppers_datum
  before_save :ensure_authentication_token, :ensure_referral_code

  # after_create :send_welcome_email_to_user

  after_create :ensure_authentication_token, :ensure_referral_code

  enum device_type: {
    android: 0,
    ios: 1
  }

  enum language: {
    en: 0,
    ar: 1
  }

  enum platform_type: {
    elgrocer: 0,
    smiles: 1
  }

  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  def ensure_referral_code
    self.referral_code ||= generate_referral_code
  end

  def login(registration_id, device_type, date_time_offset, platform_type: 0, app_version: '', language: nil)
    save_push_token!(registration_id, device_type, app_version: app_version, date_time_offset: date_time_offset,  platform_type: platform_type, language: language )
    update_login_status(date_time_offset)
    # set_platform_type(platform_type)
    save!
  end

  def update_login_status(date_time_offset)
    self.sign_in_count = sign_in_count + 1
    self.last_sign_in_at = current_sign_in_at
    self.current_sign_in_at = Time.new.utc
    self.date_time_offset = date_time_offset
  end

  def default_address
    shopper_addresses.find_by_default_address(true)
  end

  def non_live_address
    ALocationWithoutShop.where(shopper_id: self.id).first
  end

  def order_count
    Rails.cache.fetch("#{cache_key}/order_count", expires_in: 12.hours) do
      self.orders.count
    end
  end

  # Notifications! There are huge but simple to understand.

  # message_type - type of request for a notification (0 - profile update, 1 - updated order, 2 - created order, 3 - welcome, 4 - reminder)

  def update_order_notify(order, message = I18n.t('message.update'))
    # message = "Your order has been updated!"
    # if registration_id
      params = {
        message: message,
        order_id: order.id,
        message_type: 1,
        origin: 'el-grocer-api'
      }

      push_notification(registration_id, params, device_type, order, notification_id: 1)
    # end
  end

  def in_substitution_order_notify(order)
    # if registration_id
      params = {
        message: I18n.t('message.substitution'),
        order_id: order.id,
        origin: 'el-grocer-api',
        message_type: 9
      }
      push_notification(registration_id, params, device_type, order, notification_id: 2)
    # end
  end

  def online_payment_failed_order_notify(order)
    # if registration_id
      params = {
        message: I18n.t('message.online_payment_failed'),
        order_id: order.id,
        origin: 'el-grocer-api',
        message_type: 70
      }
      push_notification(registration_id, params, device_type, order, notification_id: 3)
    # end
  end

  def reminder_order_update_notify(order)
    if registration_id
      params = {
        message: I18n.t('message.update_order_notify'),
        order_id: order.id,
        message_type: 4,
        origin: 'el-grocer-api'
      }

      push_notification(registration_id, params, device_type)
    end
  end

  def cancel_order_notify(order, message, retailer_name = '')
    link = order.platform_type.eql?('smiles') ? 'https://smilesmobile.page.link/elgrocer' : 'https://elgrocershopper.page.link/JteUJsG6mynRNmMn6'
    SmsNotificationJob.perform_later(self.phone_number.phony_normalized, I18n.t('sms.cancel_with_link', reason: message, link: link))
    # if registration_id
      params = {
        message: I18n.t('sms.cancel_order', reason: message),
        order_id: order.id,
        message_type: 2,
        origin: 'el-grocer-api',
        reason: message,
        REASON: message
      }

      push_notification(registration_id, params, device_type, order, notification_id: 5)
    # end
  end

  def cancel_payment_failure(order)
    pending_payment_link = Firebase::LinkShortener.new.order_pending_payment_link(order.id, self.id, order.retailer_id)
    pending_payment_link = "https://elgrocershopper.page.link/?link=http%3A%2F%2Felgrocer.com%2Forders%3Fuser_id%3D#{self.id}%26order_id%3D#{order.id}%26orderID%3D#{order.id}%26retailer_id%3D#{order.retailer_id}&apn=com.el_grocer.shopper&isi=1040399641&ibi=elgrocer.com.ElGrocerShopper" unless pending_payment_link
    pending_payment_link = "https://smilesmobile.page.link/?link=https%3A%2F%2Fsmiles%3A%2F%2Fexy-too-trana%2F%2Felgrocer%3A%2F%2Fuser_id%3D#{self.id}%2Corder_id%3D#{order.id}%2CorderID%3D#{order.id}%2Cretailer_id%3D#{order.retailer_id}&apn=ae.etisalat.smiles&ibi=Etisalat.House&isi=1225034537&ofl=https://www.etisalat.ae/en/c/mobile/smiles.jsp" if order.platform_type.eql?('smiles')

    SmsNotificationJob.perform_later(self.phone_number.phony_normalized, I18n.t('sms.payment_failure_cancel', order_link: pending_payment_link))
    # if registration_id
      params = {
        message: I18n.t('push_message.message_002'),
        order_id: order.id,
        message_type: 2,
        origin: 'el-grocer-api'
      }

      push_notification(registration_id, params, device_type, order, notification_id: 7)
    # end
  end

  def pending_payment_notify(order)
    if registration_id
      params = {
        message: I18n.t('push_message.message_106'),
        order_id: order.id,
        retailer_id: order.retailer_id,
        message_type: 106,
        origin: 'el-grocer-api'
      }
      push_notification(registration_id, params, device_type)
    end
    pending_payment_link = Firebase::LinkShortener.new.order_pending_payment_link(order.id, self.id, order.retailer_id)
    pending_payment_link = "https://elgrocershopper.page.link/?link=http%3A%2F%2Felgrocer.com%2Forders%3Fuser_id%3D#{self.id}%26order_id%3D#{order.id}%26orderID%3D#{order.id}%26retailer_id%3D#{order.retailer_id}&apn=com.el_grocer.shopper&isi=1040399641&ibi=elgrocer.com.ElGrocerShopper" unless pending_payment_link
    pending_payment_link = "https://smilesmobile.page.link/?link=https%3A%2F%2Fsmiles%3A%2F%2Fexy-too-trana%2F%2Felgrocer%3A%2F%2Fuser_id%3D#{self.id}%2Corder_id%3D#{order.id}%2CorderID%3D#{order.id}%2Cretailer_id%3D#{order.retailer_id}&apn=ae.etisalat.smiles&ibi=Etisalat.House&isi=1225034537&ofl=https://www.etisalat.ae/en/c/mobile/smiles.jsp" if order.platform_type.eql?('smiles')
    SmsNotificationJob.perform_later(self.phone_number.phony_normalized, I18n.t('sms.payment', order_link: pending_payment_link))
  end

  def auth_payment_failed(order, message)
    if registration_id
      params = {
        message: message,
        order_id: order.id,
        retailer_id: order.retailer_id,
        message_type: 113,
        origin: 'el-grocer-api'
      }
      push_notification(registration_id, params, device_type)
    end
    pending_payment_link = Firebase::LinkShortener.new.order_pending_payment_link(order.id, self.id, order.retailer_id)
    pending_payment_link ||= "https://elgrocershopper.page.link/?link=http%3A%2F%2Felgrocer.com%2Forders%3Fuser_id%3D#{self.id}%26order_id%3D#{order.id}%26orderID%3D#{order.id}%26retailer_id%3D#{order.retailer_id}&apn=com.el_grocer.shopper&isi=1040399641&ibi=elgrocer.com.ElGrocerShopper"
    pending_payment_link = "https://smilesmobile.page.link/?link=https%3A%2F%2Fsmiles%3A%2F%2Fexy-too-trana%2F%2Felgrocer%3A%2F%2Fuser_id%3D#{self.id}%2Corder_id%3D#{order.id}%2CorderID%3D#{order.id}%2Cretailer_id%3D#{order.retailer_id}&apn=ae.etisalat.smiles&ibi=Etisalat.House&isi=1225034537&ofl=https://www.etisalat.ae/en/c/mobile/smiles.jsp" if order.platform_type.eql?('smiles')
    SmsNotificationJob.perform_later(self.phone_number.phony_normalized, I18n.t('sms.payment_failed', message: message, order_link: pending_payment_link))
  end

  def welcome_notify
    if registration_id
      params = {
        message: I18n.t('message.hello'),
        message_type: 3,
        origin: 'el-grocer-api'
      }
      push_notification(registration_id, params, device_type)
    end
  end

  def driver_at_doorstep_notify(order: nil, retailer_name: nil, driver_name: nil)
    # if registration_id
      params = {
        message: I18n.t('push_message.message_111'),
        message_type: 111,
        order_id: order.id,
        driver_name: driver_name,
        origin: 'el-grocer-api'
      }
      push_notification(registration_id, params, device_type, order, notification_id: 10)
    # end
  end

  def delivered_order_notify(order_id)
    if registration_id
      params = {
        message: I18n.t('message.delivered_order_notify'),
        order_id: order_id,
        message_type: 1,
        origin: 'el-grocer-api'
      }

      push_notification(registration_id, params, device_type)
    end
  end

  def received_wallet_amount_notify(amount, friend_name = '')
    if registration_id
      message = I18n.t('message.wallet_amount_message', amount: amount)
      message = I18n.t('message.referal_message', amount: amount, friend_name: friend_name) unless friend_name.blank?
      params = {
        message: message,
        message_type: 5,
        origin: 'el-grocer-api'
      }

      push_notification(registration_id, params, device_type)
    end
  end

  def referral_signup_notify(name)
    if registration_id
      params = {
        message: I18n.t('message.signup', name: name),
        message_type: 6,
        origin: 'el-grocer-api',
        name: name
      }

      push_notification(registration_id, params, device_type)
    end
  end

  def wallet_expiry_notify(wallet)
    if registration_id
      params = {
        message: I18n.t('message.expire', wallet: wallet.remaining_credit.round(2), expire_date: wallet.expire_date.to_date.to_formatted_s(:long)),
        message_type: 7,
        origin: 'el-grocer-api'
      }

      # push_notification(registration_id, params, device_type)
      PushNotificationJob.set(wait_until: Date.today.noon).perform_later(registration_id, params, device_type)
    end
  end

  def wallet_empty_notify
    if registration_id
      params = {
        message: I18n.t('message.empty_notify'),
        message_type: 8,
        origin: 'el-grocer-api'
      }

      # push_notification(registration_id, params, device_type)
      PushNotificationJob.set(wait_until: Date.tomorrow.noon).perform_later(registration_id, params, device_type)
    end
  end

  def delete_push_token
    if registration_id
      # UnregisterNotificationsJob.perform_later(self.registration_id, device_type)
      self.registration_id = nil
      self.device_type = nil
      save!
    end
  end

  def save_push_token!(registration_id, device_type, app_version: nil, date_time_offset: nil, platform_type: 0, language: nil)
    # if registration_id && device_type
      self.registration_id = registration_id if registration_id
      self.device_type = device_type if device_type
      self.app_version = app_version if app_version
      self.date_time_offset = date_time_offset unless date_time_offset.blank?
      self.platform_type = platform_type
      self.language = language if language
      self.is_smiles_user = true if platform_type == 1
      save!
      # register
    # end
  end

  def invoice_location_name
    if invoice_location_id
      location = Location.find_by(id: invoice_location_id)
      if location
        location.name
      else
        nil
      end
    else
      nil
    end
  end

  def average_basket_value
    orders = self.orders
    value_sum = 0
    orders_amount = 0
    if orders.size.positive?
      orders.each do |order|
        value_sum += order.total_price
        orders_amount += 1
      end
      (value_sum / orders_amount).round(2)
    else
      0
    end
  end

  def send_password_reset
    generate_token(:reset_password_token)
    self.reset_password_sent_at = Time.zone.now
    save!
    ShopperMailer.password_reset(self.id).deliver_later
  end

  def save_referral_wallet(event_id)
    # event_id: 1 for register, 2 for first order
    rule = ReferralRule.where(is_active: true, event_id: event_id).take
    if self.referred_by && rule
      referrer = Shopper.find_by(id: self.referred_by)
      info = "#{self.referral_code}'s #{event_id == 1 ? 'registration' : 'first purchase'}"
      # referree wallet entry
      ReferralWallet.create(shopper_id: self.id, amount: rule.referee_amount, remaining_credit: rule.referee_amount, expire_date: DateTime.now.days_since(rule.expiry_days), referral_rule_id: rule.id, info: info) if rule.referee_amount && rule.referee_amount.positive?
      self.received_wallet_amount_notify(rule.referee_amount) if rule.referee_amount.to_f.positive?
      # referrer wallet entry
      ReferralWallet.create(shopper_id: self.referred_by, amount: rule.referrer_amount, remaining_credit: rule.referrer_amount, expire_date: DateTime.now.days_since(rule.expiry_days), referral_rule_id: rule.id, info: info) if rule.referrer_amount && rule.referrer_amount.positive?
      referrer.referral_signup_notify(self.name || self.referral_code) if event_id == 1
      referrer.received_wallet_amount_notify(rule.referrer_amount, self.name || self.referral_code) if rule.referrer_amount.to_f.positive?
    end
  end

  def update_referral_wallet(order_id, wallet_amount_paid)
    paid_remaining = wallet_amount_paid.to_f.round(2)
    realizations = []
    self.referral_wallets.available.each do |wallet|
      # wallet = wallets.shift
      set_amount = wallet.balance > paid_remaining ? paid_remaining : wallet.balance
      realization = ReferralWalletRealization.create(referral_wallet_id: wallet.id, order_id: order_id, amount_used: set_amount)
      realizations.push(realization)
      wallet.update_column(:remaining_credit, wallet.remaining_credit.to_f.round(2) - set_amount.to_f.round(2))
      paid_remaining -= set_amount
      break if paid_remaining <= 0
    end
    send_wallet_used_email_to_user(wallet_amount_paid) unless self.email.blank?
    self.wallet_empty_notify if self.wallet_total < 1
    # wallet = ReferralWallet.where(shopper_id: :id).where('expire_date > ?', DateTime.now).order(:id).take
    # wallet.update_columns(order_id: order.id) if wallet
    realizations
  end

  def wallet_total
    # ReferralWallet.where(shopper_id: params[:shopper_id]).where('expire_date > ?', DateTime.now)
    # .sum(:amount - sum(ReferralWalletRealization.where(referral_wallet: :id)))
    # total = 0.0
    # self.referral_wallets.available.each do |wallet|
    #   total += wallet.balance
    # end
    # total.to_f

    # self.referral_wallets.sum(:remaining_credit).to_f
    self.referral_wallets.where('expire_date > ?', DateTime.now).sum(:remaining_credit).to_f.round(2)

    # self.referral_wallets.available.map.sum(&:balance).to_f
  end

  def activity(event_name)
    analytics.select { |a| a.event.name.eql?(event_name) }
  end

  def self.from_auth(params, current_user)
    # params = params.smash.with_indifferent_access
    authorization = Authorization.find_or_initialize_by(provider: params[:provider], uid: params[:uid])
    if authorization.persisted?
      if current_user
        if current_user.id == authorization.shopper_id
          user = current_user
        else
          return false
        end
      else
        user = authorization.shopper
      end
    else
      user = if current_user
               current_user
             elsif params[:email].present?
               Shopper.find_or_initialize_by(email: params[:email])
             else
               Shopper.new
             end
    end
    authorization.secret = params[:secret]
    authorization.token = params[:token]
    fallback_name = params[:name].split(' ') if params[:name]
    fallback_first_name = fallback_name.try(:first)
    fallback_last_name = fallback_name.try(:last)
    user.name = "#{params[:first_name] || fallback_first_name} #{params[:last_name] || fallback_last_name}" if user.name.blank?
    # user.last_name     ||= (params[:last_name]  || fallback_last_name)

    # if user.image_url.blank?
    #   user.image = Image.new(name: user.full_name, remote_file_url: params[:image_url])
    # end

    user.password = Devise.friendly_token[0, 10] if user.encrypted_password.blank?

    # if !user.devise_type == 2 && user.email.blank?
    #   user.save(validate: false)
    # else
      user.save
    # end
    authorization.shopper_id ||= user.id
    authorization.save
    user
  end

  def check_fraudster(card_number)
    system_config = SystemConfiguration.where(key: 'cc_fraud_check').first
    system_config = system_config.value.split('-')
    result = Redis.current.get "#{self.email.to_s}_#{self.phone_number}_cc_fraudster"
    result = result.to_s.split(',')
    result |= [card_number]
    if system_config.first.to_i.positive? && result.count > system_config.first.to_i
      self.is_blocked = true
      # self.authentication_token = generate_authentication_token
      self.save
      ::ShopperSlackNotificationJob.perform_later(self)
      # Redis.current.del "#{shopper.email}"
      return true
    else
      expiry = Redis.current.ttl("#{self.email.to_s}_#{self.phone_number}_cc_fraudster").positive? ? Redis.current.ttl("#{self.email.to_s}_#{self.phone_number}_cc_fraudster") : system_config.last.to_i.day.second.to_i
      Redis.current.set "#{self.email.to_s}_#{self.phone_number}_cc_fraudster", result.join(','), ex: expiry
    end
    false
  end

  def smiles_phone_format
    self.phone_number.phony_normalized.sub('+971', '0').sub('+', '')
  end

  private

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Shopper.exists?(column => self[column])
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless Shopper.where(authentication_token: token).exists?
    end
  end

  def generate_referral_code
    # name = Faker::Name.name unless name?
    # email = Faker::Internet.email unless email?

    loop do
      referral_code = 'REF' + [*'A'..'Z', *0..9].sample(7).join #+ SecureRandom.random_number(999).to_s
      break referral_code unless Shopper.where(referral_code: referral_code).exists?
    end
  end

  def send_welcome_email_to_user
    if self.email.present?
      ShopperMailer.welcome_shopper(self.id).deliver_later
    end
  end

  def send_wallet_used_email_to_user(amount_used)
    ShopperMailer.wallet_used(self.id, amount_used).deliver_later unless self.email.blank?
  end

  def push_notification(registration_id, params, device_type, order = nil, notification_id: nil)
    if order && order.platform_type.eql?('smiles')
      Loyalty::Smiles.new.cns_loyalty(self, params, notification_id, order: order)
    elsif registration_id
      PushNotificationJob.perform_later(registration_id, params, device_type)
    end
  end

  def phone_number_uniqueness
    return unless phone_number.phony_normalized && Shopper.where(phone_number: phone_number).where.not(id: id).any?

    errors.add(:phone_number, 'has already been taken')
  end
end
