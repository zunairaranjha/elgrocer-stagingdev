class PromotionCodes::CheckAndRealize < PromotionCodes::Base

  string :promo_code
  integer :shopper_id
  integer :retailer_id
  integer :payment_type_id, default: nil
  float :service_fee, default: nil
  float :delivery_fee, default: nil
  float :rider_fee, default: nil
  array :products

  validate :shopper_exists
  validate :retailer_exists
  validate :promocode_invalid
  validate :promocode_invalid_brands
  validate :order_value_is_enough
  validate :payment_type_invalid
  validate :orders_limit_not_matched
  # validate :retailer_promo_code_applicable

  def execute
    PromotionCode.transaction do
      # promotion_code = PromotionCode.where('code ILIKE ? ', promo_code).first
      if promotion_code.try(:can_be_used?, shopper_id, retailer_id)
        realization = create_realization!(promotion_code, shopper_id)
        promotion_code.attributes.slice('id', 'value_cents', 'value_currency',
          'code', 'allowed_realizations', 'min_basket_value').merge(promotion_code_realization_id: realization.id)
      end
    end
  end

  private

  def promotion_code
    @promotion_code ||= PromotionCode.where('code ILIKE ? ', promo_code).first
  end

  def retailer
    @retailer ||= Retailer.find_by(id: retailer_id)
  end

  def service_fees
    @service_fees ||= (service_fee.to_f > 0.0 ? service_fee.to_f : retailer.service_fee) + delivery_fee.to_f + rider_fee.to_f
  end

  def realization_params(code_id)
    {
      promotion_code_id: code_id,
      shopper_id: shopper_id,
      realization_date: Time.zone.now
    }
  end

  def create_realization!(code, shopper_id)
    realization = PromotionCodeRealization.find_by(promotion_code_id: code.id, shopper_id: shopper_id, retailer_id: nil)

    if realization.present?
      realization.realization_date = Time.zone.now
      realization.save!
    else
      realization = PromotionCodeRealization.create!(realization_params(code.id))
    end

    realization
  end

  def promocode_invalid
    errors.add(:promocode_is_invalid, 'Invalid promotion code') if promotion_code.nil? || !promotion_code.can_be_used?(shopper_id, retailer_id)
  end

  def get_position_data(product_id)
    products.detect {|prod| prod["product_id"] == product_id}
  end

  def get_product_ids
    products.map do |obj|
      obj["product_id"]
    end
  end

  def get_product_price(shop_model_data)
    (shop_model_data.price_dollars.to_f + shop_model_data.price_cents.to_f / 100).round(2)
  end

  def get_products_price(shop_model_data)
    get_product_price(shop_model_data) * get_position_data(shop_model_data.product_id)["amount"]
  end

  def get_promocode_value
    overall_value = 0.0
    brands_ids = promotion_code.all_brands ? Brand.all.ids : promotion_code.brands.ids
    db_shops = Shop.where(product_id: Product.where(id: get_product_ids, brand_id: brands_ids), retailer_id: retailer_id)

    db_shops.each do |db_shop|
      overall_value += get_products_price(db_shop)
    end
    overall_value = overall_value + service_fees
    overall_value.round(2)
  end

  def get_overall_value
    overall_value = 0.0
    products_ids = get_product_ids

    db_shops = Shop.where(product_id: products_ids, retailer_id: retailer_id)

    db_shops.each do |db_shop|
      overall_value += get_products_price(db_shop)
    end
    overall_value = overall_value + service_fees
    overall_value.round(2)
  end

  def promocode_invalid_brands
    # promotion_code = PromotionCode.where('code ILIKE ? ', promo_code).first
    if promotion_code.present?
      min_value = promotion_code.min_basket_value.to_f
      errors.add(:promotion_invalid_brands, 'Value order isnt enough to use promocode.') if get_promocode_value < min_value
      if errors[:promotion_invalid_brands].present?
        brand_names = promotion_code.brands.limit(5).pluck('name')
        #brand_names.each do |name|
        errors[:promotion_invalid_brands].push(brand_names[0])
        #end
        errors[:promotion_invalid_brands].push(min_value)
      end
    end

  end

  def order_value_is_enough
    if promotion_code.present?
      min_basket_value = promotion_code.min_basket_value.to_f
      errors.add(:order_value_is_not_enough, "#{min_basket_value} minimum basket value required to apply this promo code") if min_basket_value > 0 && get_overall_value < min_basket_value
      errors[:order_value_is_not_enough].push(min_basket_value) if errors[:order_value_is_not_enough].present?
    end
  end

  def payment_type_invalid
    if promotion_code.present?
      # payment_types = promotion_code.available_payment_types.map { |apt| I18n.t(apt.name, :scope => ["activerecord", "labels", "locations"])}
      payment_types = promotion_code.available_payment_types.ids
      errors.add(:payment_type_invalid, "This promo code is valid only for payment ids #{payment_types}") if payment_type_id.present? && (!(payment_types.include? payment_type_id) || !accepted_promocode)
    end
  end

  def orders_limit_not_matched
    errors.add(:orders_limit_not_matched, "#{promotion_code.order_limit}") if promotion_code.present? and !promotion_code.order_limit_not_exceed(shopper_id)
  end

  def accepted_promocode
    RetailerHasAvailablePaymentType.where(retailer_id: retailer_id, available_payment_type_id: payment_type_id, accept_promocode: true, retailer_service_id: 1).exists?
  end  
end
