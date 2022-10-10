class Order < ActiveRecord::Base
  before_create :randomize_id

  ############# Associations ##############
  belongs_to :shopper, optional: true
  belongs_to :retailer, optional: true
  belongs_to :shopper_address, optional: true
  belongs_to :delivery_slot, optional: true

  has_many :order_positions, dependent: :destroy
  has_many :order_positions_views
  has_many :order_subs_views
  has_many :products, through: :order_positions
  has_one :promotion_code_realization
  has_one :order_feedback
  has_many :order_allocations
  has_many :employees, through: :order_allocations
  has_one :active_allocation, -> { active }, class_name: 'OrderAllocation'
  has_one :active_employee, through: :active_allocation, source: :employee
  belongs_to :retailer_delivery_zone, optional: true
  belongs_to :credit_card, optional: true
  has_many :order_substitutions, dependent: :destroy
  has_many :analytics, as: :owner
  has_many :online_payment_logs
  has_many :payment_thresholds
  has_one :employee
  belongs_to :delivery_channel, optional: true
  belongs_to :picker, optional: true, class_name: 'Employee', foreign_key: 'picker_id'
  belongs_to :checkout, optional: true, class_name: 'Employee', foreign_key: 'checkout_person_id'
  has_one :order_collection_detail
  has_one :collector_detail, through: :order_collection_detail
  has_one :vehicle_detail, through: :order_collection_detail
  has_one :pickup_location, through: :order_collection_detail
  has_one :color, through: :vehicle_detail
  has_one :vehicle_model, through: :vehicle_detail
  has_one :pickup_loc, through: :order_collection_detail
  belongs_to :retailer_service, optional: true
  has_one :orders_datum
  has_many :smiles_transaction_logs
  has_many :product_proposals
  has_many :image, as: :record, dependent: :destroy
  accepts_nested_attributes_for :image, allow_destroy: true
  include Concerns::SmilesHelper

  ############# Scopes ##############
  scope :orders_pending, -> { where('orders.status_id = 0') }
  scope :orders_accepted, -> { where('orders.status_id = 1') }
  scope :orders_en_route, -> { where('orders.status_id = 2') }
  scope :orders_delivered, -> { where('orders.status_id = 5') }
  scope :orders_completed, -> { where('orders.status_id = 3') }
  scope :with_promotion_code, -> { Order.joins(:promotion_code_realization) }
  scope :without_promotion_code, lambda { Order.joins(
    'LEFT OUTER JOIN promotion_code_realizations ON promotion_code_realizations.order_id = orders.id')
                                               .where('promotion_code_realizations.id IS null') }
  scope :with_wallet_amount_paid, -> { where('orders.wallet_amount_paid > 0') }
  scope :orders_instant, -> { where('delivery_slot_id is null or delivery_slot_id = 0') }
  scope :orders_scheduled, -> { where('delivery_slot_id > 0') }

  def self.ransackable_scopes(_opts)
    [:retailer_id_includes, :hours_eq, :auto_refresh_trigger]
  end

  scope :retailer_id_includes, lambda { |search|
    current_scope = self
    current_scope = current_scope.where(retailer_id: search.split(','))
    current_scope
  }

  scope :hours_eq, lambda { |additional|
    self.where('orders.estimated_delivery_at <= ?', (Time.now + additional.to_i.hours))
  }

  scope :auto_refresh_trigger, lambda { |trigger|

  }

  # before_update :send_order_placement_to_user, if: :is_accepted?
  # before_update :accept_order_notify, if: :is_accepted?
  before_update :on_status_update, if: :status_id_changed?
  before_save :clear_cart
  # after_create :post_analytics

  attr_accessor :min_basket_value

  enum language: {
    en: 0,
    ar: 1
  }

  enum device_type: { android: 0, ios: 1, web: 2 }

  enum delivery_method: {
    delivery: 0,
    collect: 1
  }

  enum delivery_vehicle: {
    bike: 0,
    car: 1
  }

  enum platform_type: {
    elgrocer: 0,
    smiles: 1,
  }

  def retailer_company_name
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      self.retailer.send("company_name_#{I18n.locale.to_s}")
    else
      read_attribute(:retailer_company_name)
    end
  end

  def retailer_company_address
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      self.retailer.send("company_address_#{I18n.locale.to_s}")
    else
      read_attribute(:retailer_company_address)
    end
  end

  after_commit on: [:create] do
    # send_order_placement_to_user
    create_batch_locus_task if self.status_id == SystemConfiguration.get_key_value('locus:send-on-status-id').to_i
    #create analytics and kafka on create commit
    create_analytic(date_time_offset: date_time_offset)
  end

  after_commit on: [:update] do
    self.update_column(:updated_at, Time.now)
    if status_id_previously_changed?
      case status_id
      when 1
        # create_locus_task
      when 9
        clear_allocation
        create_locus_task
        create_booking
        # assign_locus_task
        OrderAllocationJob.perform_later(self)
      when 11
        # create_locus_task
        update_amount_locus_task if final_amount.to_f.nonzero? && !([3,4].include? self.payment_type_id)
        batch_update_amount_locus if final_amount.to_f.nonzero?
      end
    end
    # create_locus_task if self.status_id_previously_changed? && self.status_id == 1
    # make order status check dynamic, hardcoded just for testing
    create_batch_locus_task if self.status_id_previously_changed? && self.status_id == SystemConfiguration.get_key_value('locus:send-on-status-id').to_i
  end

  before_destroy :revert_wallet

  def on_status_update
    detail = nil
    case self.status_id
    when 1
      self.update_column(:accepted_at, Time.now)
      accept_order_notify
      # create_locus_task
      # delivered_status_job_for_accept
    when 2
      detail = "With variance #{self.price_variance} AED"
      self.update_column(:processed_at, Time.now)
      send_order_placement_to_user
      clear_allocation
      # delivered_status_job
      self.shopper.save_referral_wallet(2) if self.shopper.orders.where('status_id in (2,3,5)').count == 0 #add wallet amount on first order and notify users
    when 3
      self.update_column(:approved_at, Time.now)
      self.shopper.save_referral_wallet(2) if self.shopper.orders.where('status_id in (2,3,5)').count == 0 #add wallet amount on first order and notify users
    when 4
      self.update_column(:canceled_at, Time.now)
      if self.payment_type_id == 3
        if card_detail.present? && card_detail['ps'].to_s.eql?('adyen') && card_detail['auth_amount'].present? && card_detail['is_void'].to_i.zero?
          AdyenJob.perform_later('void_authorization', self, self.merchant_reference)
        elsif self.status_id_was != -1
          PayfortJob.perform_later('void_authorization', self, nil, self.merchant_reference, self.card_detail.to_h['auth_amount'].to_i / 100.0)
        end
      end
      if self.payment_type_id == 4
        smiles_transactions_to_rollback(self)
      else
        earn_smile_points_rollback(self)
      end
      cancel_booking
      cancel_locus_task
      cancel_locus_batch_task
      clear_allocation
      revert_wallet
      revert_shop_stock
    when 5
      clear_allocation
    when 8
      edit_order_notify
      edit_order_job
    when 9
      # clear_allocation
      # create_booking
      # assign_locus_task
      # OrderAllocationJob.perform_later(self)
      Slack::SlackNotification.new.send_checkout_order_notification(self.id) rescue ''
    when 11
      clear_allocation
      # create_booking
      # OrderAllocationJob.perform_later(self)
      OrderStatusUpdateJob.perform_later(self)
    end
    create_analytic(detail, date_time_offset: date_time_offset) unless self.status_id == 7
    self.date_time_offset = date_time_offset_was if date_time_offset_changed?
    update_customfields_to_partners
  end

  def create_analytic(detail = nil, date_time_offset: nil)
    Analytic.post_activity("Order #{self.status.humanize}", self, detail: detail,
                           date_time_offset: date_time_offset)

    OrderDataStreamingJob.perform_later(self, self.status_id_was)
  end

  def post_analytics
    create_analytic(date_time_offset: date_time_offset)
  end

  def clear_cart
    return unless status_id.zero? && [-1, 0, 8].include?(status_id_was)

    ShopperCartProduct.where({ retailer_id: retailer_id, shopper_id: shopper_id }).delete_all
  end

  def clear_allocation
    self.order_allocations.where(order_allocations: { is_active: true }).update_all(is_active: false)
  end

  def create_booking
    Resque.enqueue(PartnerIntegrationJob, self.id, 2)
  end

  def create_locus_task
    Resque.enqueue(PartnerIntegrationJob, self.id, PartnerIntegration.integration_types[:locus_post_order])
  end

  def create_batch_locus_task
    Resque.enqueue(PartnerIntegrationJob, self.id, PartnerIntegration.integration_types[:locus_batch_post_order])
  end

  def cancel_booking
    Resque.enqueue(PartnerIntegrationJob, self.id, 3)
  end

  def cancel_locus_task
    Resque.enqueue(PartnerIntegrationJob, self.id, PartnerIntegration.integration_types[:locus_cancel_order])
  end

  def cancel_locus_batch_task
    Resque.enqueue(PartnerIntegrationJob, self.id, PartnerIntegration.integration_types[:locus_batch_cancel_order])
  end

  def reschedule_locus_batch_task
    Resque.enqueue(PartnerIntegrationJob, self.id, PartnerIntegration.integration_types[:locus_batch_reschedule_order])
  end

  def revert_shop_stock
    if Retailer.where(id: retailer_id, with_stock_level: true).exists?
      ops = OrderPosition.select(:product_id, :amount).where(order_id: id)
      ops.each do |op|
        shop = Shop.unscoped.find_by(retailer_id: retailer_id, product_id: op.product_id)
        shop.available_for_sale = shop.available_for_sale.to_i + op.amount
        shop.is_available = true if shop.available_for_sale.positive?
        shop.save
      end
    end
  end

  def assign_locus_task
    Resque.enqueue(PartnerIntegrationJob, self.id, PartnerIntegration.integration_types[:locus_assign_order])
  end

  def update_customfields_to_partners
    Resque.enqueue(PartnerIntegrationJob, self.id, PartnerIntegration.integration_types[:locus_update_customfields])
    Resque.enqueue(PartnerIntegrationJob, self.id, PartnerIntegration.integration_types[:locus_batch_update_custom_fields])
    Resque.enqueue(WarehouseJob, { update_stage: true, order_id: id })
  end

  def update_amount_locus_task
    Resque.enqueue(PartnerIntegrationJob, self.id, PartnerIntegration.integration_types[:locus_update_amount],)
  end

  def batch_update_amount_locus
    Resque.enqueue(PartnerIntegrationJob, self.id, PartnerIntegration.integration_types[:locus_batch_amount_update])
  end

  def revert_wallet
    # if (self.wallet_amount_paid.present? && self.wallet_amount_paid > 0)
    realizations = ReferralWalletRealization.where(order_id: self.id)
    realizations.each do |realization|
      wallet = realization.referral_wallet
      wallet.remaining_credit += realization.amount_used
      wallet.save
      realization.delete
    end
    # end
  end

  enum statuses: {
    waiting_for_online_payment_detail: -1,
    pending: 0,
    accepted: 1,
    en_route: 2,
    completed: 3,
    canceled: 4,
    delivered: 5,
    in_substitution: 6,
    in_edit: 8,
    online_payment_failed: 7,
    ready_for_checkout: 9,
    waiting_payment_approval: 10,
    ready_to_deliver: 11,
    checking_out: 12,
    payment_approved: 13,
    payment_rejected: 14
  }

  def statuses_array
    [
      { status_id: -1, name: 'waiting_for_online_payment_detail' },
      { status_id: 0, name: 'pending' },
      { status_id: 1, name: 'accepted' },
      { status_id: 2, name: 'en_route' },
      { status_id: 3, name: 'completed' },
      { status_id: 4, name: 'canceled' },
      { status_id: 5, name: 'delivered' },
      { status_id: 6, name: 'in_substitution' },
      { status_id: 7, name: 'online_payment_failed' },
      { status_id: 8, name: 'in_edit' },
      { status_id: 9, name: 'ready_for_checkout' },
      { status_id: 10, name: 'waiting_payment_approval' },
      { status_id: 11, name: 'ready_to_deliver' },
      { status_id: 12, name: 'checking_out' },
      { status_id: 13, name: 'payment_approved' },
      { status_id: 14, name: 'payment_rejected' }
    ]
  end

  def status
    case status_id
    when -1
      'waiting_for_online_payment_detail'
    when 0
      'pending'
    when 1
      'accepted'
    when 2
      'en_route'
    when 3
      'completed'
    when 4
      'canceled'
    when 5
      'delivered'
    when 6
      'in_substitution'
    when 7
      'online_payment_failed'
    when 8
      'in_edit'
    when 9
      'ready_for_checkout'
    when 10
      'waiting_payment_approval'
    when 11
      'ready_to_deliver'
    when 12
      'checking_out'
    when 13
      'payment_approved'
    when 14
      'payment_rejected'
    end
  end

  enum delivery_types: {
    instant: 0,
    schedule: 1
  }

  def shopper_address_type
    case shopper_address_type_id
    when 0
      'apartment'
    when 1
      'house'
    when 2
      'office'
    end
  end

  enum feedback_status: { feedback_pending: 0, feedback_received: 1, feedback_user_canceled: 2 }

  enum user_canceled_type: {
    retailer_canceled: 1,
    shopper_canceled: 2,
    dashboard_canceled: 3,
    delete_card_canceled: 4,
    payment_canceled: 5,
    delete_account_canceled: 6
  }

  def is_accepted?
    self.status_id_changed? && self.status_id == 1
  end

  def is_canceled?
    self.status_id_changed? && self.status_id == 4
  end

  def payment_type
    case payment_type_id
    when 1
      'Cash on delivery'
    when 2
      'Credit Card on delivery'
    when 3
      'Online Payment'
    when 4
      'Smiles Points'
    end
  end

  def average_value
    op = order_positions
    value_sum = 0
    product_amount = 0
    if op.size > 0
      op.each do |position|
        value_sum += ((position.shop_price_dollars + position.shop_price_cents.to_f / 100).to_f).round(2) * position.amount
        product_amount += position.amount
      end
      value_sum / product_amount
    else
      0
    end
  end

  def price_currency
    order_positions.first.try(:shop_price_currency)
  end

  def promotion_discount
    ((promotion_code_realization.discount_value.to_i.positive? ? promotion_code_realization.discount_value.to_i : promotion_code_realization.promotion_code.value_cents
    ) / 100.0).round(2)
  end

  def total_price_without_discount
    order_positions.to_a.sum(&:full_price).round(2)
  end

  def total_price
    price = total_value.to_f
    price += total_services_fee
    price -= promotion_discount if promotion_code_realization.present?
    price.round(2)
  end

  def total_price_to_capture
    price = order_positions.where(was_in_shop: true).to_a.sum(&:full_price).round(2)
    price += total_services_fee
    price -= promotion_discount if promotion_code_realization.present?
    price -= wallet_amount_paid.to_f
    price.round(2)
  end

  def total_services_fee
    (service_fee.to_f + rider_fee.to_f + delivery_fee.to_f).round(2)
  end

  def total_vat
    vat_amount = total_price_without_discount - ((total_price_without_discount / (100.0 + vat)) * 100.0)
    vat_amount += total_services_fee - ((total_services_fee / (100.0 + vat)) * 100.0)
    vat_amount.round(2)
  end

  def total_commission
    order_positions.to_a.sum(&:commission_value).round(2)
  end

  def average_size
    op = order_positions
    product_amount = 0
    if op.size > 0
      op.each do |position|
        product_amount += position.amount
      end
      product_amount / op.size
    else
      0
    end
  end

  def mark_substituting(from_employee: false)
    self.status_id = 6
    save
    self.substituting_order_notify(from_employee)
  end

  def mark_substituted(is_notify_shopper: false, current_employee: false, delivery_vehicle: nil)
    if current_employee and [-1, 6].include?(self.status_id)
      self.status_id = 9
      self.processed_at = Time.now
      self.delivery_vehicle = delivery_vehicle if delivery_vehicle && self.retailer_service_id == 1
    elsif [-1, 6].include?(self.status_id)
      self.status_id = 1
    end
    save
    if is_notify_shopper
      self.shopper.update_order_notify(self)
    elsif (order_allocation = self.order_allocations.where(is_active: true).first)
      params = {
        'message': I18n.t('push_message.message_102'),
        'order_id': self.id,
        'message_type': 102,
        'retailer_id': self.retailer_id
      }
      PushNotificationJob.perform_later(order_allocation.employee.registration_id, params, 0, true)
    else
      self.retailer.selected_products_notify(self.id)
    end
    Resque.enqueue(WarehouseJob, { modify_order: true, order_id: self.id })
  end

  def send_order_placement_to_user
    ShopperMailer.order_placement(self.id).deliver_later
  end

  def send_substitution_email_to_user(subs_link)
    ShopperMailer.substitution(self.id, subs_link).deliver_later
  end

  def accept_order_notify
    self.shopper.update_order_notify(self, I18n.t('message.accept_order'))
    self.retailer.update_order_notify(self.id)
  end

  def substituting_order_notify(from_employee = false)
    shopper = self.shopper
    shopper.in_substitution_order_notify(self)
    self.retailer.update_order_notify(self.id) unless from_employee
    #send sms to shopper
    # subs_link = Firebase::LinkShortener.new.order_short_link(self.id, self.shopper_id)
    # subs_link = "https://elgrocershopper.page.link/?link=http%3A%2F%2Felgrocer.com%2Forder%2Fsubstitution%3Fuser_id%3D#{self.shopper_id}%26order_id%3D#{self.id}%26substituteOrderID%3D#{self.id}&apn=com.el_grocer.shopper&isi=1040399641&ibi=elgrocer.com.ElGrocerShopper" unless subs_link

    subs_link = if self.platform_type.eql?('smiles')
                  "https://smilesmobile.page.link/?link=https%3A%2F%2Fsmiles%3A%2F%2Fexy-too-trana%2F%2Felgrocer%3A%2F%2Fuser_id%3D#{self.shopper_id}%2Corder_id%3D#{self.id}%2CsubstituteOrderID%3D#{self.id}&apn=ae.etisalat.smiles&ibi=Etisalat.House&isi=1225034537&ofl=https://www.etisalat.ae/en/c/mobile/smiles.jsp"
                else
                  # subs_link = Firebase::LinkShortener.new.order_short_link(self.id, self.shopper_id)
                  "https://elgrocershopper.page.link/?link=http%3A%2F%2Felgrocer.com%2Forder%2Fsubstitution%3Fuser_id%3D#{self.shopper_id}%26order_id%3D#{self.id}%26substituteOrderID%3D#{self.id}&apn=com.el_grocer.shopper&isi=1040399641&ibi=elgrocer.com.ElGrocerShopper" unless subs_link
                end
    SmsNotificationJob.perform_later(shopper.phone_number.phony_normalized, I18n.t('sms.substitution', subs_link: subs_link)) unless shopper.phone_number.blank?
    # send email
    send_substitution_email_to_user(subs_link)
  end

  def delivered_status_job
    OrderDeliveryStatusJob.set(wait: 2.hours).perform_later(self.id)
  end

  def delivered_status_job_for_accept
    OrderDeliveryStatusJob.set(wait: 4.hours).perform_later(self.id)
  end

  def selecting_products_notify
    order_allocation = self.order_allocations.where(is_active: true).first
    if order_allocation
      params = {
        'message': I18n.t('push_message.message_102'),
        'order_id': self.id,
        'message_type': 102,
        'retailer_id': self.retailer_id
      }
      PushNotificationJob.perform_later(order_allocation.employee.registration_id, params, 0, true)
    else
      self.retailer.selecting_products_notify(self.id)
    end
  end

  def edit_order_job
    EditOrderJob.set(wait: 30.minutes).perform_later(self.id, self.payment_type_id)
  end

  def edit_order_notify
    # self.retailer.edit_order_notify(self.id)
  end

  def pending_order_notify
    self.retailer.pending_order_notify(self.id)
  end

  def as_json(options = {})
    super.merge({ 'total_commission' => total_commission, 'total_price' => total_price })
  end

  def to_xml(options = {})
    options.merge!(methods: [:total_commission, :total_price])
    super(options)
  end

  def schedule_for
    if delivery_slot.present?
      delivery_slot.schedule_for(self.estimated_delivery_at)
    else
      I18n.t('order_placement.asap')
    end
  end

  ransacker :audit_area, formatter: proc { |v|
    v = v.to_i
    case v
    when 1
      data = Order.where(payment_type_id: 3, status_id: 4).order('created_at desc').ids
    when 2
      data = Order.where(payment_type_id: 3, status_id: [-1, 0, 1, 6, 8, 9, 10, 11]).order('created_at desc').ids
    when 3
      data = Order.where(payment_type_id: 3, status_id: 7).order('created_at desc').ids
    when 4
      data = Order.where(payment_type_id: 3, status_id: [2, 3, 5, 12, 13, 14]).order('created_at desc').ids
    when 5
    end
    data.blank? ? nil : data
  } do |parent|
    parent.table[:id]
  end

  private

  def randomize_id
    begin
      self.id = SecureRandom.random_number(2_147_483_600)
    end while Order.where(id: self.id).exists?
  end
end
