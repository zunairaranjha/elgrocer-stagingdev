class PromotionCodes::V2CheckAndRealize < PromotionCodes::Base

  string :promo_code
  integer :shopper_id
  integer :retailer_id
  integer :payment_type_id, default: nil
  float :service_fee, default: nil
  float :delivery_fee, default: nil
  float :rider_fee, default: nil
  array :products
  integer :service_id, default: 1
  string :date_time_offset, default: nil

  validate :shopper_exists
  validate :retailer_exists
  validate :promocode_invalid
  validate :promocode_expired
  validate :max_allowed_realizations
  validate :for_retailer
  validate :already_not_used
  validate :promocode_invalid_brands
  validate :order_value_is_enough
  validate :payment_type_invalid
  validate :orders_limit_not_matched
  validate :for_shopper
  validate :for_service
  # validate :retailer_promo_code_applicable

  def execute
    PromotionCode.transaction do
      promotion_code = PromotionCode.where('code ILIKE ? ', promo_code).first
      if promotion_code.try(:can_be_used?, shopper_id, retailer_id)
        realization = create_realization!(promotion_code, shopper_id)
        promotion_code.attributes.slice('id', 'value_currency', 'code', 'allowed_realizations', 'min_basket_value')
                      .merge(promotion_code_realization_id: realization.id, value_cents: discount_value)
      end
    end
  end

  private

  def discount_value
    if promotion_code.percentage_off.to_f.positive?
      [(brand_products_value * promotion_code.percentage_off.to_f).floor, promotion_code.value_cents].min
    else
      promotion_code.value_cents
    end
  end

  def realization_params(code_id)
    {
      promotion_code_id: code_id,
      shopper_id: shopper_id,
      realization_date: Time.zone.now,
      discount_value: discount_value,
      date_time_offset: date_time_offset
    }
  end

  def create_realization!(code, shopper_id)
    realization = PromotionCodeRealization.find_by(promotion_code_id: code.id, shopper_id: shopper_id, retailer_id: nil)

    if realization.present?
      realization.realization_date = Time.zone.now
      realization.discount_value = discount_value
      realization.date_time_offset = date_time_offset
      realization.save!
    else
      realization = PromotionCodeRealization.create!(realization_params(code.id))
    end

    realization
  end

  def promotion_code_exist
    @promotion_code_exist ||= PromotionCode.where('code ILIKE ? ', promo_code).first.nil? ? 0 : 1
  end

  def promotion_code
    @promotion_code ||= PromotionCode.where('code ILIKE ? ', promo_code).first
  end

  def retailer
    @retailer ||= Retailer.find_by(id: retailer_id)
  end

  def service_fees
    @service_fees ||= retailer_has_service.service_fee + delivery_fees
  end

  def delivery_fees
    delivery_fee = 0
    if retailer_has_service.retailer_service_id == 1
      delivery_fee = retailer_delivery_zone.rider_fee.to_f + (
        if (get_products_value + retailer_has_service.service_fee) < retailer_delivery_zone.min_basket_value
          retailer_delivery_zone.delivery_fee.to_f
        else
          0
        end)
    end
    delivery_fee
  end

  def promocode_invalid
    errors.add(:promocode_is_invalid, I18n.t('error_message.promocode_is_invalid')) unless promotion_code_exist == 1
  end

  def promocode_expired
    errors.add(:promocode_expired, I18n.t('error_message.promocode_expired')) if promotion_code_exist == 1 && !promotion_code.expired_now?
  end

  def max_allowed_realizations
    errors.add(:max_allowed_realizations, I18n.t('error_message.max_allowed_realizations')) if promotion_code_exist == 1 && !promotion_code.proper_number_of_realizations?
  end

  def for_retailer
    errors.add(:not_for_retailer, I18n.t('error_message.not_for_retailer')) if promotion_code_exist == 1 && !promotion_code.all_retailers && !promotion_code.for_retailer?(retailer_id)
  end

  def already_not_used
    errors.add(:already_used, I18n.t('error_message.already_used')) if promotion_code_exist == 1 && promotion_code.used_by_shopper?(shopper_id, retailer_id)
  end

  def get_position_data(product_id)
    products.detect { |prod| prod['product_id'] == product_id }
  end

  def get_product_ids
    products.map do |obj|
      obj['product_id']
    end
  end

  def get_product_price(shop_model_data)
    if shop_model_data.shop_promotions.present?
      shop = shop_model_data.shop_promotions.first
      shop.price
    else
      (shop_model_data.price_dollars.to_f + shop_model_data.price_cents.to_f / 100).round(2)
    end
  end

  def get_products_price(shop_model_data)
    get_product_price(shop_model_data) * get_position_data(shop_model_data.id)['amount']
  end

  def get_brand_specific_value
    (brand_products_value + service_fees).round(2)
  end

  def get_overall_value
    (get_products_value + service_fees).round(2)
  end

  def get_products_value
    return @products_value unless @products_value.to_i < 1

    @products_value = 0.0
    db_shops = get_products

    db_shops.each do |db_shop|
      @products_value += get_products_price(db_shop)
    end
    @products_value.round(2)
  end

  def brand_products_value
    return @brand_products_value unless @brand_products_value.to_i < 1

    @brand_products_value =
      if promotion_code.all_brands
        get_products_value
      else
        brand_ids = promotion_code.brands.ids
        overall_value = 0.0
        db_shops = get_products.select { |p| brand_ids.include? p.brand_id }

        db_shops.each do |db_shop|
          overall_value += get_products_price(db_shop)
        end
        overall_value.round(2)
      end
  end

  def promocode_invalid_brands
    if promotion_code_exist == 1 && !promotion_code.all_brands && get_brand_specific_value < promotion_code.min_basket_value.to_f
      brand_names = I18n.locale.to_s.downcase.eql?('en') ? promotion_code.brands.limit(5).pluck('name') * (', ') : promotion_code.brands.limit(5).pluck('name_ar') * (', ')
      errors.add(:promotion_invalid_brands, I18n.t('error_message.promotion_invalid_brands', brand_names: brand_names, min_basket_value: promotion_code.min_basket_value.to_f))
    end
  end

  def order_value_is_enough
    if promotion_code_exist == 1
      min_basket_value = promotion_code.min_basket_value.to_f
      errors.add(:order_value_is_not_enough_for_realize, I18n.t('error_message.order_value_is_not_enough_for_realize', min_basket_value: min_basket_value)) if promotion_code_exist == 1 && (min_basket_value.positive? && get_overall_value < min_basket_value)
      # errors[:order_value_is_not_enough].push(min_basket_value) if errors[:order_value_is_not_enough].present?
    end
  end

  def payment_type_invalid
    if promotion_code_exist == 1
      # payment_types = promotion_code.available_payment_types.map { |apt| I18n.t(apt.name, :scope => ["activerecord", "labels", "locations"])}
      # payment_types = promotion_code.available_payment_types.ids
      errors.add(:payment_type_invalid, I18n.t('error_message.payment_type_invalid')) if payment_type_id.present? && (!(promotion_code.available_payment_types.ids.include? payment_type_id) || !accepted_promocode)
    end
  end

  def orders_limit_not_matched
    if promotion_code_exist == 1
      errors.add(:orders_limit_not_matched, I18n.t('error_message.orders_limit_not_matched', order_limit: promotion_code.order_limit)) unless promotion_code.order_limit_not_exceed(shopper_id)
    end
  end

  def for_shopper
    if promotion_code_exist == 1
      errors.add(:not_for_shopper, I18n.t('error_message.not_for_shopper')) unless promotion_code.for_shopper?(shopper_id)
    end
  end

  def for_service
    if promotion_code_exist == 1
      errors.add(:not_for_service, service_id.to_i == 1 ? I18n.t('error_message.only_for_delivery') : I18n.t('error_message.only_for_cnc')) unless promotion_code.for_service?(service_id.to_i)
    end
  end

  def retailer_has_service
    @retailer_has_service ||= RetailerHasService.find_by(retailer_id: retailer.id, retailer_service_id: service_id, is_active: true)
  end

  def shopper_address
    @shopper_address ||= ShopperAddress.find_by(shopper_id: shopper_id, default_address: true)
  end

  def retailer_delivery_zone
    @retailer_delivery_zone ||= retailer.retailer_delivery_zone_with(shopper_address)
  end

  def get_products
    return @all_products if @all_products.present?

    @all_products = Product.joins(:shops).includes(:brand, :subcategories, :categories)
                           .select('products.*, shops.id AS shop_id, shops.price_cents, shops.price_dollars, shops.is_promotional, shops.price_currency')
                           .where(id: get_product_ids, shops: { retailer_id: retailer.id })
    ActiveRecord::Associations::Preloader.new.preload(@all_products, :shop_promotions, { where: ("retailer_id = #{retailer.id} AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: [:end_time, :start_time] })
    @all_products
  end

  def accepted_promocode
    RetailerHasAvailablePaymentType.where(retailer_id: retailer_id, available_payment_type_id: payment_type_id, accept_promocode: true, retailer_service_id: service_id).exists?
  end
end
