class PromotionCode < ActiveRecord::Base

  ############# Attribute Accessor ###############
  attr_accessor :city, :locations, :select_all_brands, :select_all_retailers, :title_en, :title_ar, :description_en, :description_ar, :name_en, :name_ar

  ############# Validation ###############
  validates :code, uniqueness: { case_sensitive: false }
  validates_presence_of :value_cents, :value_currency, :allowed_realizations, :start_date, :end_date,
                        :code # , :retailers
  validates_numericality_of :value_cents, greater_than: 0, only_integer: true
  validates_numericality_of :allowed_realizations, greater_than_or_equal_to: 0, less_than_or_equal_to: 999999
  validates_numericality_of :realizations_per_retailer, less_than_or_equal_to: :realizations_per_shopper
  validates_numericality_of :realizations_per_shopper, greater_then_or_equal_to: :realizations_per_retailer
  validate :valid_date_range_required
  # validate :title_presence
  validate :name_presence

  ############# Associations ##############
  has_many :realizations, class_name: 'PromotionCodeRealization',
           foreign_key: :promotion_code_id, dependent: :restrict_with_exception
  has_and_belongs_to_many :retailers
  has_and_belongs_to_many :brands
  has_many :promotion_code_available_payment_types
  has_many :available_payment_types, through: :promotion_code_available_payment_types
  has_many :promotion_codes_retailers
  has_one :image, as: :record, dependent: :destroy
  accepts_nested_attributes_for :image, allow_destroy: true

  ############# Enum ##############
  enum promotion_type: {
    marketing: 0,
    customer: 1,
    free_shipping: 2,
    invisible: 4,
    revenue: 6
  }

  monetize :value_cents, with_model_currency: :value_currency, numericality: {
    greater_than: 0
  }

  def can_be_used?(shopper_id, retailer_id)
    is_active? && not_used_by_shopper?(shopper_id, retailer_id) && for_retailer?(retailer_id)
  end

  def used_by_shopper?(shopper_id, retailer_id)
    (realizations_per_shopper != 0 &&
      realizations.successful.where(shopper_id: shopper_id).count >= realizations_per_shopper) ||
      (realizations_per_retailer != 0 &&
        realizations.successful.where(shopper_id: shopper_id, retailer_id: retailer_id).count >= realizations_per_retailer)
  end

  def for_shopper?(shopper_id)
    if shopper_ids.blank?
      true
    else
      shopper_ids.include?(shopper_id)
    end
  end

  def for_service?(service_id)
    if retailer_service_id.to_i.zero?
      true
    else
      retailer_service_id == service_id
    end
  end

  def not_used_by_shopper?(shopper_id, retailer_id)
    !used_by_shopper?(shopper_id, retailer_id)
  end

  def for_retailer?(retailer_id)
    if all_retailers
      true
    else
      retailers.blank? || retailers.pluck(:id).include?(retailer_id)
    end
  end

  def is_active?
    proper_number_of_realizations? && expired_now?
  end

  def order_limit_not_exceed(shopper_id)
    orders_limit = order_limit.split('-')
    if orders_limit.length > 1
      lower_limit = orders_limit[0].to_i
      upper_limit = orders_limit[1].to_i
      limit_exceed = Order.where(shopper_id: shopper_id).where.not(status_id: 4).count.between?(lower_limit, upper_limit)
    else
      limit_exceed = Order.where(shopper_id: shopper_id).where.not(status_id: 4).count == orders_limit.first.to_i
    end
    limit_exceed
  end

  def realizations_value_per_retailer(retailer_id)
    realizations.successful.where(retailer_id: retailer_id).count * value
  end

  def name
    "#{code} :  #{value} AED"
  end

  def proper_number_of_realizations?
    allowed_realizations.zero? || (realizations.successful.count < allowed_realizations)
  end

  def order_expired_now?(created_at)
    started_with_respect_to_order?(created_at) && not_finished_with_respect_to_order?(created_at)
  end

  def started_with_respect_to_order?(created_at)
    start_date.nil? || (start_date < created_at)
  end

  def not_finished_with_respect_to_order?(created_at)
    end_date.nil? || (end_date.to_time.utc >= created_at.beginning_of_day.utc)
  end

  def expired_now?
    started? && not_finished?
  end

  def started?
    start_date.nil? || (start_date < Time.zone.now)
  end

  def not_finished?
    end_date.nil? || (end_date.to_time.utc >= Time.now.beginning_of_day.utc)
  end

  def valid_date_range_required
    errors.add(:end_date, 'must be later than start_date') if (start_date && end_date) && (end_date < start_date)
  end

  def self.generate_code
    loop do
      code = (0...6).map { rand(65..90).chr }.join
      break code unless PromotionCode.where('code ILIKE ? ', code).exists?
    end
  end

  def title
    title = self.send("title_#{I18n.locale.to_s}") if (I18n.locale != :en) && I18n.available_locales.include?(I18n.locale)
    title.present? && title || self.send('title_en')
  end

  def title_en
    data['title_en']
  end

  def title_ar
    data['title_ar']
  end

  def description
    if (I18n.locale != :en) && I18n.available_locales.include?(I18n.locale)
      value = self.send("description_#{I18n.locale.to_s}")
    end
    value.present? && value || self.send('description_en')
  end

  def description_en
    data['description_en']
  end

  def description_ar
    data['description_ar']
  end

  def name
    name = self.send("name_#{I18n.locale.to_s}") if (I18n.locale != :en) && I18n.available_locales.include?(I18n.locale)
    name.present? && name || self.send('name_en')
  end

  def name_en
    data['name_en']
  end

  def name_ar
    data['name_ar']
  end

  def external_transaction_id
    data['external_transaction_id']
  end

  def photo_url
    image&.photo_url
  end

  def title_presence
    if data.with_indifferent_access[:title_en].blank?
      data['title_en'] = ''
      errors.add(:title_en, "can't be empty")
    end
    if data.with_indifferent_access[:title_ar].blank? && data.with_indifferent_access[:title_en].blank?
      data['title_ar'] = ''
      errors.add(:title_ar, "can't be empty")
    end
  end

  def name_presence
    if data.with_indifferent_access[:name_en].blank?
      data['name_en'] = ''
      errors.add(:name_en, "can't be empty")
    end
    if data.with_indifferent_access[:name_ar].blank? && data.with_indifferent_access[:name_en].blank?
      data['name_ar'] = ''
      errors.add(:name_ar, "can't be empty")
    end
  end
end
