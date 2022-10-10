class Retailer < ActiveRecord::Base
  time_of_day_attr :delivery_slot_skip_hours, :schedule_order_reminder_hours, :cutoff_time
  enum time_zones: %i[Asia/Dubai Asia/Riyadh]
  attr_accessor :select_all_rcategories, :ret_category_ids, :source # , :min_basket_value, :retailer_delivery_zones_id

  # include RetailerIndexing
  # include CollectionSearchable
  include GoogleMessaging
  include AppleNotifications
  # include RegisterNotifications
  include RetailerOpenHours
  include ZonesWithPoint
  extend FriendlyId
  friendly_id :slug_candidates, use: %i[finders slugged]

  devise :database_authenticatable, :recoverable,
         :rememberable, :trackable, :validatable
  has_attached_file :photo, styles: { medium: '300x300>', icon: '50x50#' }, default_url: 'https://api.elgrocer.com/images/:style/missing.png'
  has_attached_file :photo1, styles: { large: '1000x1000', medium: '300x300>', icon: '50x50#' }, default_url: 'https://api.elgrocer.com/images/:style/missing.png'
  validates_attachment_content_type :photo, :photo1, content_type: /\Aimage\/.*\Z/

  validates :company_name, :email, :location_id, presence: true
  validates :password, :password_confirmation, presence: true, on: :create
  validates :password, confirmation: true
  validates_numericality_of :show_pending_order_hours, greater_than: 1, only_integer: true
  validates_presence_of :latitude, :longitude
  validates_presence_of :date_time_offset

  has_many :shops, dependent: :destroy
  has_many :products, through: :shops
  has_many :brands, -> { distinct }, through: :products
  has_many :product_categories, through: :products
  has_many :subcategories, -> { distinct }, through: :product_categories, source: :category
  has_many :categories, -> { distinct }, through: :subcategories, source: :parent
  has_many :retailer_categories
  has_many :rcategories, -> { distinct }, through: :retailer_categories, source: :category
  has_many :orders
  has_many :order_positions, through: :orders
  has_many :retailer_operators
  has_many :retailer_has_locations, dependent: :destroy
  has_many :retailer_reviews
  has_many :retailer_has_available_payment_types, -> { delivery }
  has_many :retailer_delivery_payment_types, -> { delivery }, class_name: 'RetailerHasAvailablePaymentType'
  has_many :retailer_click_and_collect_payment_types, -> { click_and_collect }, class_name: 'RetailerHasAvailablePaymentType'
  has_many :available_payment_types, through: :retailer_has_available_payment_types
  has_many :delivery_payment_types, through: :retailer_delivery_payment_types, class_name: 'AvailablePaymentType', source: :available_payment_type
  has_many :click_and_collect_payment_types, through: :retailer_click_and_collect_payment_types, class_name: 'AvailablePaymentType', source: :available_payment_type
  has_many :csv_imports
  has_many :shopper_favourite_retailers
  has_many :patrons, class_name: 'Shopper', through: :shopper_favourite_retailers, source: :shopper
  has_many :retailer_opening_hours
  has_many :retailer_delivery_zones, dependent: :destroy
  has_many :delivery_zones, through: :retailer_delivery_zones
  has_many :retailer_reports
  has_many :employees
  has_many :shop_promotions
  has_many :scheduled_closed_timings, class_name: 'RetailerOpeningHour', through: :retailer_delivery_zones, source: :retailer_opening_hours

  belongs_to :location, optional: true
  has_one :city, through: :location
  has_one :partner_integration

  has_many :locations, through: :retailer_has_locations
  has_and_belongs_to_many :promotion_codes
  has_many :promotion_code_realizations
  has_many :shop_product_logs, as: :owner
  has_many :retailer_store_types
  has_many :store_types, through: :retailer_store_types
  belongs_to :retailer_group, optional: true
  has_many :retailer_has_services, dependent: :destroy
  has_one :delivery_service, -> { delivery }, class_name: 'RetailerHasService'
  has_one :click_and_collect_service, -> { click_and_collect }, class_name: 'RetailerHasService'
  has_many :delivery_slots
  has_many :cc_slots, -> { click_and_collect }, class_name: 'DeliverySlot'
  has_many :available_slots, -> { order(:slot_date).limit(2) } # , through: :retailer_delivery_zones
  has_many :next_available_slots, -> { where(slot_rank: 1, retailer_service_id: RetailerService.services[:delivery]).order(:slot_date) }, class_name: 'AvailableSlot' # , source: :available_slots
  has_many :next_available_slots_cc, -> { where(slot_rank: 1, retailer_service_id: RetailerService.services[:click_and_collect]).order(:slot_date) }, class_name: 'AvailableSlot' # , source: :available_slots
  has_many :retailer_available_slots
  has_many :next_slot_delivery, -> { where(retailer_service_id: RetailerService.services[:delivery]) }, class_name: 'RetailerNextAvailableSlot'
  has_many :next_slot_cc, -> { where(retailer_service_id: RetailerService.services[:click_and_collect]) }, class_name: 'RetailerNextAvailableSlot'
  has_and_belongs_to_many :banners
  has_many :pickup_locations
  has_one :image, as: :record, dependent: :destroy
  belongs_to :retailer_types, foreign_key: 'retailer_type', optional: true, class_name: 'RetailerType'
  has_many :product_proposals
  accepts_nested_attributes_for :delivery_zones
  accepts_nested_attributes_for :retailer_has_services, allow_destroy: true
  accepts_nested_attributes_for :delivery_service
  accepts_nested_attributes_for :click_and_collect_service
  accepts_nested_attributes_for :delivery_slots
  accepts_nested_attributes_for :cc_slots
  accepts_nested_attributes_for :image, allow_destroy: true

  before_create :ensure_authentication_token!
  before_update :status_change_slack_notify, if: :is_opened_changed?

  scope :opened, -> { where('retailers.is_opened IS TRUE') }
  scope :closed, -> { where('retailers.is_opened IS FALSE') }
  scope :active_closed, -> { where('retailers.is_active IS TRUE AND retailers.is_opened IS FALSE') }
  scope :is_generate_report, -> { where('retailers.is_generate_report IS TRUE') }
  scope :stock_level, ->(id) { where(id: id, with_stock_level: true) }
  scope :without_delivery_zone, lambda {
    eager_load(:retailer_delivery_zones).where(retailer_delivery_zones: { id: nil })
  }
  scope :opened_hours, lambda {
    joins(:retailer_opening_hours)
      .in_opened_hours
  }

  scope :with_zone_containg_lonlat, lambda { |lonlat|
    joins(:delivery_zones).with_point(lonlat)
  }

  scope :all_with_zone, lambda { |lon, lat|
    with_zone_containg_lonlat("POINT (#{lon} #{lat})")
      .where("retailers.is_active IS TRUE AND opening_time<>''")
      .joins("LEFT JOIN retailer_opening_hours on retailer_opening_hours.retailer_id = retailers.id and retailer_opening_hours.open < #{Time.now.seconds_since_midnight} AND retailer_opening_hours.close > #{Time.now.seconds_since_midnight} AND retailer_opening_hours.day = #{Time.now.wday + 1}")
      .joins("LEFT JOIN retailer_opening_hours as droh on droh.retailer_delivery_zone_id = retailer_delivery_zones.id and #{Time.now.seconds_since_midnight} between droh.close AND droh.open AND droh.day = #{Time.now.wday + 1}")
      .joins("LEFT JOIN retailer_opening_hours as chour on chour.retailer_delivery_zone_id = retailer_delivery_zones.id and chour.close > #{Time.now.seconds_since_midnight} AND chour.day = #{Time.now.wday + 1}")
      .distinct
  }

  scope :all_for_api, lambda { |seconds_since_midnight, wday|
    where("retailers.is_active IS TRUE AND opening_time<>''")
      .joins("LEFT JOIN retailer_opening_hours on retailer_opening_hours.retailer_id = retailers.id and retailer_opening_hours.open < #{seconds_since_midnight} AND retailer_opening_hours.close > #{seconds_since_midnight} AND retailer_opening_hours.day = #{wday}")
      .joins("LEFT JOIN retailer_opening_hours as droh on droh.retailer_delivery_zone_id = retailer_delivery_zones.id and #{seconds_since_midnight} between droh.close AND droh.open AND droh.day = #{wday}")
      .joins("LEFT JOIN retailer_opening_hours as chour on chour.retailer_delivery_zone_id = retailer_delivery_zones.id and chour.close > #{seconds_since_midnight} AND chour.day = #{wday}")
      .joins('LEFT JOIN retailer_store_types ON retailer_store_types.retailer_id = retailers.id')
      .select("retailers.*, (array_agg(retailer_delivery_zones.min_basket_value))[1] min_basket_value, (array_agg(retailer_delivery_zones.delivery_fee))[1] delivery_fee, (array_agg(retailer_delivery_zones.rider_fee))[1] rider_fee, (array_agg(retailer_delivery_zones.id))[1] retailer_delivery_zones_id, (array_agg(delivery_zones.id))[1] delivery_zones_id,
              (array_agg(retailer_delivery_zones.delivery_type))[1] retailer_delivery_type, (is_opened and is_active and count(retailer_opening_hours.open)>0 and count(droh.open) = 0) open_now, max(droh.open) will_reopen, max(chour.close) will_close, ARRAY_REMOVE(ARRAY_AGG(retailer_store_types.store_type_id),NULL) store_category_ids")
      .group('retailers.id')
  }

  scope :for_api_with_point, lambda { |lon, lat, seconds_since_midnight, wday|
    with_zone_containg_lonlat("POINT (#{lon} #{lat})").all_for_api(seconds_since_midnight, wday)
  }

  scope :for_api_without_point, lambda { |seconds_since_midnight, wday|
    joins('LEFT JOIN retailer_delivery_zones on retailer_delivery_zones.retailer_id = retailers.id')
      .joins('LEFT JOIN delivery_zones on delivery_zones.id = retailer_delivery_zones.delivery_zone_id')
      .all_for_api(seconds_since_midnight, wday)
  }

  scope :for_cc_api_with_point, lambda { |lon, lat, radius|
    select("retailers.id, retailers.report_parent_id, retailers.company_name, retailers.company_name_ar, retailers.slug, retailers.is_opened, retailers.is_show_recipe, retailers.retailer_type, retailers.retailer_group_id,
                                  retailers.latitude, retailers.longitude, retailer_has_services.delivery_slot_skip_time AS delivery_slot_skip_hours, retailer_has_services.cutoff_time, retailer_has_services.delivery_type AS retailer_delivery_type,
                                  retailers.photo_file_name, retailers.photo_content_type, retailers.photo_file_size, retailers.photo_updated_at, retailers.location_id,
                                  retailers.photo1_file_name, retailers.photo1_content_type, retailers.photo1_file_size, retailers.photo1_updated_at,
                                  ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{lon} #{lat})')) AS distance,
                                  ARRAY_REMOVE(ARRAY_AGG(retailer_store_types.store_type_id),NULL) store_category_ids,
                                  retailer_has_services.min_basket_value AS min_basket_value, retailer_has_services.service_fee AS service_fee, retailers.is_featured, retailers.with_stock_level")
      .group('retailers.id, retailer_has_services.min_basket_value, retailer_has_services.service_fee, retailer_has_services.delivery_slot_skip_time, retailer_has_services.cutoff_time, retailer_has_services.delivery_type')
      .having("ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{lon} #{lat})')) <= #{radius}")
      .order("ST_DistanceSphere(ST_GeomFromText('POINT ('|| retailers.longitude ||' ' || retailers.latitude ||')'), ST_GeomFromText('POINT (#{lon} #{lat})'))")
  }

  scope :for_cc_api_without_point, lambda {
    select("retailers.id, retailers.report_parent_id, retailers.company_name, retailers.company_name_ar, retailers.slug, retailers.is_opened, retailers.is_show_recipe, retailers.retailer_type, retailers.retailer_group_id,
                                  retailers.latitude, retailers.longitude, retailer_has_services.delivery_slot_skip_time AS delivery_slot_skip_hours, retailer_has_services.cutoff_time, retailer_has_services.delivery_type AS retailer_delivery_type,
                                  retailers.photo_file_name, retailers.photo_content_type, retailers.photo_file_size, retailers.photo_updated_at, retailers.location_id,
                                  retailers.photo1_file_name, retailers.photo1_content_type, retailers.photo1_file_size, retailers.photo1_updated_at,
                                  ARRAY_REMOVE(ARRAY_AGG(retailer_store_types.store_type_id),NULL) store_category_ids,
                                  retailer_has_services.min_basket_value AS min_basket_value, retailer_has_services.service_fee AS service_fee, retailers.is_featured, retailers.with_stock_level")
      .group('retailers.id, retailer_has_services.min_basket_value, retailer_has_services.service_fee, retailer_has_services.delivery_slot_skip_time, retailer_has_services.cutoff_time, retailer_has_services.delivery_type')
  }

  scope :eager_load_for_all_delivery_retailers, lambda {
    includes(:city, :next_slot_delivery, :retailer_group, :image)
  }

  scope :eager_load_for_all_cc_retailers, lambda {
    includes(:city, :next_slot_cc, :retailer_group)
  }

  scope :delivery_ret_preload_payment_types,lambda { |retailers|
    ActiveRecord::Associations::Preloader.new.preload(retailers, :retailer_delivery_payment_types, { where: {available_payment_type_id: [1,2,3] }})
    ActiveRecord::Associations::Preloader.new.preload(retailers, :delivery_payment_types)
  }

  scope :cc_ret_preload_payment_types,lambda { |retailers|
    ActiveRecord::Associations::Preloader.new.preload(retailers, :retailer_click_and_collect_payment_types, { where: {available_payment_type_id: [1,2,3] }})
    ActiveRecord::Associations::Preloader.new.preload(retailers, :click_and_collect_payment_types)
  }

  # after_commit on: [:create] do
  #  Resque.enqueue(Indexer, :create, self.class.name, id)
  # end

  # after_commit on: [:update] do
  #   update_profile_notify
  # end

  # after_commit on: [:destroy] do
  #  Resque.enqueue(Indexer, :delete, self.class.name, id)
  #  update_dependent_indexes
  # end

  def slug_candidates
    [:company_name, %i[company_name id], randomize_slug]
  end

  def should_generate_new_friendly_id?
    # company_name_changed? || super
    company_name_changed? || super if slug.blank?
  end

  def to_param
    id.to_s
  end

  def company_name
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.send("company_name_#{I18n.locale.to_s}")
    end
    value || read_attribute(:company_name)
  end

  def company_address
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.send("company_address_#{I18n.locale.to_s}")
    end
    value || read_attribute(:company_address)
  end

  def bg_photo_url
    value = image&.photo_url('large') if I18n.locale != :en && I18n.available_locales.include?(I18n.locale)
    value || photo1_url('large')
  end

  # def update_dependent_indexes
  #  shops.each do |s|
  #    Resque.enqueue(Indexer, :update, s.class.name, s.id)
  #  end
  # end

  scope :top, lambda {
    select('retailers.id, retailers.company_name, count(orders.id) AS orders_count').
      joins(:orders).
      group('retailers.id').
      order('orders_count DESC')
  }

  enum device: {
    android: 0,
    ios: 1
  }

  enum delivery_types: {
    instant: 0,
    schedule: 1,
    instant_and_schedule: 2
  }

  def delivery_type
    case delivery_type_id
    when 0
      'instant'
    when 1
      'schedule'
    when 2
      'instant_&_scheduled'
    end
  end

  # enum retailer_type: {
  #   supermarket: 0,
  #   hypermarket: 1,
  #   speciality: 2
  # }

  def human_id
    "R#{format('%05d', self.id)}"
  end

  def login(registration_id, device_type, hardware_id)
    ensure_authentication_token!
    save_push_token!(registration_id, device_type, hardware_id)
    update_login_status
    save!
  end

  def update_login_status
    self.sign_in_count = self.sign_in_count + 1
    self.last_sign_in_at = self.current_sign_in_at
    self.current_sign_in_at = Time.new
  end

  def human_opening_time
    ret = ''
    begin
      s = JSON.parse(self.opening_time)
      oh = s['opening_hours']
      cs = s['closing_hours']
      ret << "Opening hours (Week Days: #{oh[0]}, Thursday: #{oh[1]}, Friday: #{oh[2]})<br>"
      ret << "Closing hours (Week Days: #{cs[0]}, Thursday: #{cs[1]}, Friday: #{cs[2]})"
    rescue Exception => e

    end
    ret
  end

  def store_timigs
    s = JSON.parse(self.opening_time)
    "#{s['opening_hours'][0]} - #{s['closing_hours'][0]}"
  end

  def name
    company_name
  end

  # TODO: Optimization, currently returns static values
  def total_income
    # Rails.cache.fetch("#{cache_key}/total_income", expires_in: 1.hours) do
    #   sum = 0
    #   self.order_positions.joins(:order).where({:orders => { :canceled_at => nil }}).find_each do |op|
    #     sum += op.full_income
    #   end
    #   sum.round(2)
    # end
    0.0
  end

  # TODO: Optimization, currently returns static values
  def current_month_income
    # Rails.cache.fetch("#{cache_key}/current_month_income", expires_in: 1.hours) do
    #   sum = 0
    #   self.order_positions.joins(:order).where("orders.created_at > ? ", Date.today.beginning_of_month().to_s(:db)).where({:orders => { :canceled_at => nil }}).find_each do |op|
    #     sum += op.full_income
    #   end
    #   sum.round(2)
    # end
    0.0
  end

  def photo_from_url(url)
    self.photo = open(url)
  end

  def photo_url
    photo ? photo.url(:medium) : nil
  end

  def photo1_url(size = 'medium')
    photo1 ? photo1.url(size) : nil
  end

  def ensure_authentication_token!
    self.authentication_token = generate_authentication_token if authentication_token.blank?
  end

  def retailer_delivery_zone_with(shopper_address)
    # retailer_delivery_zones.joins(:delivery_zone).with_point(shopper_address.lonlat.to_s).first
    retailer_delivery_zones.where(retailer_delivery_zones: { delivery_zone_id: delivery_zones.with_point(shopper_address.lonlat.to_s) }).first
    # retailer_delivery_zones.first rescue nil
  end

  def is_schedule_closed?(shopper_address)
    scheduled_closed_timings.where("#{Time.now.seconds_since_midnight} between close AND open AND day = #{Time.now.wday + 1}").where(retailer_delivery_zones: { delivery_zone_id: delivery_zones.with_point(shopper_address.lonlat.to_s) }).present?
  end

  def location_name
    location ? location.name : 'Not specified'
  end

  def delivery_slot_skip_time
    # close / (60.0 * 60.0)
    TimeOfDayAttr.l(delivery_slot_skip_hours) # unless delivery_slot_skip_hours.blank?
  end

  def schedule_order_reminder_time
    # open / (60.0 * 60.0)
    TimeOfDayAttr.l(schedule_order_reminder_hours) # unless schedule_order_reminder_hours.blank?
  end

  def order_cutoff_time
    # cutoff_time/ (60.0 * 60.0)
    TimeOfDayAttr.l(cutoff_time)
  end

  # Notifications! There are huge but simple to understand.
  # message_type - type of request for a notification (0 - profile update, 1 - updated order, 2 - created order, 3 - welcome)

  def update_profile_notify
    self.retailer_operators.each do |ro|
      ro.update_profile_notify
    end
  end

  def new_order_notify(order_id)
    self.retailer_operators.each do |ro|
      ro.new_order_notify(order_id)
    end
  end

  def cancel_order_notify(order_id)
    self.retailer_operators.each do |ro|
      ro.cancel_order_notify(order_id)
    end
  end

  def update_order_notify(order_id)
    self.retailer_operators.each do |ro|
      ro.update_order_notify('updated', order_id)
    end
  end

  def process_order_notify(order_id)
    self.retailer_operators.each do |ro|
      ro.update_order_notify('processed', order_id)
    end
  end

  def approve_order_notify(order_id)
    self.retailer_operators.each do |ro|
      ro.approve_order_notify(order_id)
    end
  end

  def selecting_products_notify(order_id)
    self.retailer_operators.each do |ro|
      ro.selecting_products_notify(order_id)
    end
  end

  def selected_products_notify(order_id)
    self.retailer_operators.each do |ro|
      ro.selected_products_notify(order_id)
    end
  end

  def select_order_notify(order_id, hardware_id)
    self.retailer_operators.each do |ro|
      ro.select_order_notify(order_id, hardware_id)
    end
  end

  def unselect_order_notify(order_id, hardware_id)
    self.retailer_operators.each do |ro|
      ro.unselect_order_notify(order_id, hardware_id)
    end
  end

  def edit_order_notify(order_id)
    self.retailer_operators.each do |ro|
      ro.edit_order_notify(order_id)
    end
  end

  def pending_order_notify(order_id)
    self.retailer_operators.each do |ro|
      ro.pending_order_notify(order_id)
    end
  end

  def online_payment_failed_notify(order_id)
    self.retailer_operators.each do |ro|
      ro.online_payment_failed_notify(order_id)
    end
  end

  def status_change_slack_notify
    ::RetailerSlackNotificationJob.perform_later(id, self.source || 'web/admin')
  end

  def save_push_token!(registration_id, device_type, hardware_id)
    retailer_id = self.id
    if registration_id and device_type and hardware_id
      global_ret_op = RetailerOperator.find_by(hardware_id: hardware_id)
      global_ret_op.destroy if global_ret_op
      ret_op = self.retailer_operators.find_by(hardware_id: hardware_id)
      if ret_op
        ret_op.registration_id = registration_id
        ret_op.device_type = device_type
        # ret_op.register
      else
        new_ret_op = RetailerOperator.create({ retailer_id: retailer_id, hardware_id: hardware_id, device_type: device_type, registration_id: registration_id })
        # new_ret_op.register
      end
    end
  end

  def delete_push_token(registration_id, hardware_id)
    if registration_id and hardware_id
      if ro = retailer_operators.find_by(registration_id: registration_id, hardware_id: hardware_id)
        ro.delete_push_token
      end
    end
  end

  # TODO: Returning static values
  def average_rating
    # Rails.cache.fetch("#{cache_key}/average_rating", expires_in: 24.hours) do
    #   sum_of_all = 0
    #   if self.retailer_reviews.count > 0
    #     sum_of_all += self.retailer_reviews.average(:overall_rating)
    #     sum_of_all += self.retailer_reviews.average(:delivery_speed_rating)
    #     sum_of_all += self.retailer_reviews.average(:order_accuracy_rating)
    #     sum_of_all += self.retailer_reviews.average(:quality_rating)
    #     sum_of_all += self.retailer_reviews.average(:price_rating)
    #   end

    #   result = sum_of_all / 5

    #   result
    # end
    4.5
  end

  # TODO: Returning static values
  def average_ratings
    # Rails.cache.fetch("#{cache_key}/average_ratings", expires_in: 24.hours) do
    #   result = {
    #     :overall_rating => self.retailer_reviews.average(:overall_rating),
    #     :delivery_speed_rating => self.retailer_reviews.average(:delivery_speed_rating),
    #     :order_accuracy_rating => self.retailer_reviews.average(:order_accuracy_rating),
    #     :quality_rating => self.retailer_reviews.average(:quality_rating),
    #     :price_rating => self.retailer_reviews.average(:price_rating)
    #   }
    #   result
    # end
    {
      overall_rating: 4.5,
      delivery_speed_rating: 4.5,
      order_accuracy_rating: 4.5,
      quality_rating: 4.5,
      price_rating: 4.5
    }
  end

  def send_password_reset
    generate_token(:reset_password_token)
    self.reset_password_sent_at = Time.zone.now
    save!
    RetailerMailer.password_reset(self.id).deliver_later
  end

  def convert_opening_time
    unless opening_time.blank?
      json = JSON.parse(opening_time)
      # PARSING JSON
      week_days_opening = json['opening_hours'][0] # week days
      week_days_closing = json['closing_hours'][0]
      thursday_opening = json['opening_hours'][1] # thursday
      thursday_closing = json['closing_hours'][1]
      friday_opening = json['opening_hours'][2] # friday
      friday_closing = json['closing_hours'][2]
      ##################

      # WEEK STARTING FROM SUNDAY
      [1, 2, 3, 4, 7].each { |day| prepare_opening_hour(day, week_days_opening, week_days_closing) }
      prepare_opening_hour(5, thursday_opening, thursday_closing)
      prepare_opening_hour(6, friday_opening, friday_closing)
    end
  end

  def delivery_areas
    Rails.cache.fetch("#{cache_key}/delivery_areas", expires_in: 1.hours) do
      delivery_zones.map { |delivery_zone| delivery_zone.to_lonlat_array }.compact
    end
  end

  def delivery_areas_json
    Rails.cache.fetch("#{cache_key}/delivery_areas_json", expires_in: 1.hours) do
      delivery_zones.map { |delivery_zone| delivery_zone.latlon_coords }.to_json
    end
  end

  def in_delivery_zones?(shopper_address)
    Rails.cache.fetch("#{cache_key}/in_delivery_zones?#{shopper_address}", expires_in: 60.seconds) do
      return false unless shopper_address.lonlat.present?
      delivery_zones.with_point(shopper_address.lonlat.to_s).present?
    end
  end

  def subcategory_ids_uniq
    Rails.cache.fetch("#{cache_key}/subcategory_ids_uniq", expires_in: 15.minutes) do
      subcategories.select(:id).uniq.ids
    end
  end

  def category_ids_uniq
    Rails.cache.fetch("#{cache_key}/category_ids_uniq", expires_in: 15.minutes) do
      Category.where(id: subcategory_ids_uniq).select(:parent_id).uniq.map(&:parent_id) + [shops.where(is_promotional: true).count > 0 ? 1 : 0]
      # Category.where(id: sbids).select('distinct parent_id').map(&:parent_id)
    end
  end

  def brand_ids_uniq
    Rails.cache.fetch("#{cache_key}/brand_ids_uniq", expires_in: 15.minutes) do
      products.select(:brand_id).uniq.map(&:brand_id)
    end
  end

  def is_opened?
    Rails.cache.fetch("#{cache_key}/is_opened?", expires_in: 60.seconds) do
      is_active && is_opened && in_open_hours?
    end
  end

  def currently_opened(retailer_delivery_zone_id)
    Rails.cache.fetch("#{cache_key}/currently_opened#{retailer_delivery_zone_id}", expires_in: 60.seconds) do
      is_active && is_opened && in_open_hours? && !scheduled_closed_timings.where("#{Time.now.seconds_since_midnight} between close AND open AND day = #{Time.now.wday + 1}").where(retailer_delivery_zone_id: retailer_delivery_zone_id).present?
    end
  end

  def in_open_hours?
    Rails.cache.fetch("#{cache_key}/in_open_hours?", expires_in: 60.seconds) do
      retailer_opening_hours.in_opened_hours.present?
    end
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
      break token unless Retailer.where(authentication_token: token).first
    end
  end

  def prepare_opening_hour(day, open, close)
    opening_hour = retailer_opening_hours.find_by_day(day)
    if !opening_hour
      opening_hour = RetailerOpeningHour.new
      opening_hour.day = day
      opening_hour.open = open
      opening_hour.close = close
      retailer_opening_hours << opening_hour
    else
      opening_hour.open = open
      opening_hour.close = close
    end

    opening_hour.save!
  end

  private

  def randomize_slug
    begin
      new_slug = "#{self.name}-#{SecureRandom.random_number(999999).to_s}"
    end while Retailer.where(slug: new_slug).exists?
    new_slug
  end

end
