class Orders::Update < Orders::Base

  integer :retailer_id
  integer :shopper_address_id
  integer :shopper_id
  integer :payment_type_id
  array :products
  integer :promotion_code_realization_id, default: nil
  string :shopper_note, default: nil
  float :wallet_amount_paid, default: 0
  integer :delivery_slot_id, default: nil
  float :service_fee, default: nil
  float :delivery_fee, default: nil
  float :rider_fee, default: nil
  string :language, default: 'en'
  integer :vat, default: 0
  integer :recipe_id, default: nil
  integer :device_type, default: nil
  integer :order_id
  integer :card_id, default: nil
  string :merchant_reference, default: nil
  integer :auth_amount, default: nil
  integer :week, default: nil
  boolean :realization_present, default: true

  # validate :order_exists
  validate :order_in_edit
  validate :retailer_exists
  validate :retailer_is_opened
  validate :shopper_exists
  validate :shopper_address_exists
  validate :location_is_covered
  validate :products_are_not_empty
  validate :retailer_has_payment_type
  validate :order_value_is_enough
  validate :promocode_invalid
  validate :promocode_invalid_brands
  validate :wallet_amount_is_enough
  validate :delivery_slot_exists
  validate :delivery_slot_invalid
  # validate :delivery_slot_orders_limit
  validate :delivery_slot_products_limit
  validate :retailer_delivery_type_invalid

  def execute
    I18n.locale = :en
    Order.transaction do
      clear(order_id)
      order = update_order!
      create_positions!(order.id)
      if promo_realization.present? && promotion_code.can_be_used?(shopper_id, retailer_id)
        order.update_attributes(promotion_code_realization: promo_realization)
        promo_realization.update_attributes(retailer: order.retailer)
      end
      retailer.update_order_notify(order.id) if order.status_id == 0
      order.update_column(:total_value , get_overall_value)
      # order.update(status_id: -1) if payment_type_id == 3 and card_id.to_i == 0
      order
    end
  end

  private

  def order
    @order ||= Order.find_by(id: order_id)
  end

  def clear(order_id)
    OrderPosition.where(order_id: order_id).delete_all
    OrderSubstitution.where(order_id: order_id).delete_all
    PromotionCodeRealization.where(order_id: order_id).where.not(id: realization_id).update_all(retailer_id: nil, order_id: nil)
  end

  def realization_id
    if realization_present
      @realization_id ||= promotion_code_realization_id.to_i > 0 ? promotion_code_realization_id : order.promotion_code_realization.try(:id)
      realization_present = @realization_id.present?
      @realization_id
    else
      nil
    end
  end

  def promo_realization
    @promo_realization ||= PromotionCodeRealization.find_by(id: realization_id)
  end

  def promotion_code
    @promotion_code ||= promo_realization.try(:promotion_code)
  end

  def shopper_address
    @shopper_address ||= ShopperAddress.find(shopper_address_id)
  end

  def retailer_has_location
    @retailer_has_location = RetailerHasLocation.find_by(location_id: shopper_address.location_id, retailer_id: retailer_id)
  end

  def retailer
    @retailer ||= Retailer.find(retailer_id)
  end

  def shopper
    @shopper ||= Shopper.find(shopper_id)
  end

  def credit_card
    @credit_card ||= CreditCard.find(card_id)
  end

  def order_params
    params = {
        retailer_id: retailer.id,
        shopper_id: shopper.id,
        shopper_address_id: shopper_address.id,

        retailer_phone_number: retailer.phone_number,
        retailer_company_name: retailer.company_name,
        retailer_opening_time: retailer.opening_time,
        retailer_company_address: retailer.company_address,

        retailer_location_id: retailer.location_id,
        retailer_location_name: retailer.location_name,

        retailer_contact_person_name: retailer.contact_person_name,

        retailer_street: retailer.street,
        retailer_building: retailer.building,
        retailer_apartment: retailer.apartment,
        retailer_flat_number: retailer.flat_number,

        retailer_contact_email: retailer.contact_email,
        retailer_delivery_range: retailer.delivery_range,

        shopper_phone_number: shopper.phone_number,
        shopper_name: shopper.name,

        shopper_address_name: shopper_address.address_name,
        shopper_address_area: shopper_address.area,
        shopper_address_street: shopper_address.street,
        shopper_address_building_name: shopper_address.building_name,
        shopper_address_apartment_number: shopper_address.apartment_number,
        shopper_address_longitude: shopper_address.longitude,
        shopper_address_latitude: shopper_address.latitude,
        shopper_address_location_address: shopper_address.location_address,
        shopper_address_type_id: shopper_address.address_type_id,
        shopper_address_location_id: shopper_address.location_id,
        shopper_address_location_name: shopper_address.location_name,
        shopper_address_additional_direction: shopper_address.additional_direction,
        shopper_address_floor: shopper_address.floor,
        shopper_address_house_number: shopper_address.house_number,

        payment_type_id: payment_type_id,
        shopper_note: shopper_note,

        wallet_amount_paid: wallet_amount_paid.to_f.round(2),
        service_fee: service_fee.to_f.round(2),
        delivery_fee: delivery_fee.to_f.round(2),
        rider_fee: rider_fee.to_f.round(2),
        language: language,
        vat: vat,
        retailer_delivery_zone_id: retailer_delivery_zone.try(:id),
        credit_card_id: card_id,
        merchant_reference: merchant_reference,
        retailer_service_id: 1
    }

    # params[:delivery_slot_id] = delivery_slot_id if delivery_slot.present?
    params[:estimated_delivery_at] = (delivery_slot.present? ? cal_estd_dlvry_at : Time.now + 1.hour) unless (order.delivery_slot_id == delivery_slot_id and (week.to_i == 0 or (order.estimated_delivery_at + 1.day).strftime('%V').to_i == week.to_i))
    params[:delivery_type_id] = delivery_slot.present? ? 1 : 0 #0=instant,1=schedule
    params[:device_type] = device_type || shopper.device_type
    params[:card_detail] = credit_card.attributes.merge(auth_amount: auth_amount) if card_id.to_i > 0

    params
  end

  def update_order!
    order.status_id = (order.payment_type_id == 3 and order.payment_type_id == payment_type_id and order.status_id == -1) ? -1 : 0
    if order.payment_type_id == 3 and order.payment_type_id != payment_type_id and order.card_detail && order.card_detail['auth_amount']
      PayfortJob.perform_later('void_authorization', order, nil, order.merchant_reference, order.card_detail['auth_amount'].to_i/100.0)
    elsif order.payment_type_id != 3 and payment_type_id == 3
      order.status_id = -1
    end
    order.update(order_params.compact)
    order.delivery_slot_id = delivery_slot.present? ? delivery_slot_id : nil
    order.min_basket_value = retailer.delivery_zones.with_point(shopper_address.lonlat.to_s).maximum('retailer_delivery_zones.min_basket_value')
    shopper.update_referral_wallet(order.id, wallet_amount_paid.to_f.round(2)) if wallet_amount_paid > 0 # update wallet if wallet payment option is selected
    order.save
    order
  end

  def retailer_delivery_zone
    @rdz ||= retailer.retailer_delivery_zone_with(shopper_address)
  end

  def get_position_data(product_id)
    products.detect {|prod| prod["product_id"] == product_id}
  end


  def create_positions!(order_id)
    products_ids = products.map do |obj|
      obj["product_id"]
    end

    new_positions = []

    # db_products = Product.joins(:brand, :subcategories, :categories).where(id: products_ids)
    # db_products = Product.unscoped.where(id: products_ids)
    db_products = Product.unscoped.includes(:brand, :subcategories, :categories).where(id: products_ids)
    # db_shops = Shop.unscoped.where(product_id: products_ids, retailer_id: retailer.id, is_published: true)
    db_shops = Shop.unscoped.where(product_id: products_ids, retailer_id: retailer.id)

    db_products.each do |pr|
      db_shop = nil

      db_shops.each do |sh|
        if sh.product_id == pr.id
          db_shop = sh
        end
      end

      shop_id = db_shop ? db_shop.id : nil
      shop_price_cents = db_shop ? db_shop.price_cents : 0
      shop_price_dollars = db_shop ? db_shop.price_dollars : 0
      shop_price_currency = db_shop ? db_shop.price_currency : 'AED'
      shop_is_promotional = db_shop ? db_shop.is_promotional : false


      if retailer.commission_value
        shop_commission_value = retailer.commission_value
      else
        shop_commission_value = 0
      end


      if db_shop.present?
        if db_shop.commission_value.present?
          db_shop_commission_value = db_shop.commission_value
        end
      end



      product_brand_name = pr.brand ? pr.brand.name : 'Other'
      product_category_name = pr.categories.size > 0 ? pr.categories[0].name : 'Other'
      product_subcategory_name = pr.subcategories.size > 0 ? pr.subcategories[0].name : 'Other'


      order_position = {
          order_id: order_id,
          product_id: pr.id,
          shop_id: shop_id,
          amount: get_position_data(pr.id)["amount"],
          product_barcode: pr.barcode,
          brand_id: pr.brand_id,
          product_brand_name: product_brand_name,
          product_name: pr.name,
          product_description: pr.description,
          product_shelf_life: pr.shelf_life,
          product_size_unit: pr.size_unit,
          product_country_alpha2: pr.country_alpha2,
          product_location_id: pr.location_id,
          category_id: pr.categories[0].try(:id),
          product_category_name: product_category_name,
          subcategory_id: pr.subcategories[0].try(:id),
          product_subcategory_name: product_subcategory_name,
          shop_price_cents: shop_price_cents,
          shop_price_dollars: shop_price_dollars,
          shop_price_currency: shop_price_currency,
          commission_value: shop_commission_value,
          is_promotional: shop_is_promotional
      }

      new_positions.push(order_position)

    end
    OrderPosition.transaction do
      OrderPosition.create(new_positions)
    end
  end

  def slot
    @slot ||= delivery_slot_id.present? ? true : false
  end

  def delivery_slot
    @delivery_slot ||= DeliverySlot.find_by(id: delivery_slot_id, is_active: true) if slot.present?
  end

  def get_product_ids
    products.map do |obj|
      obj["product_id"]
    end
  end

  def get_product_price(shop_model_data)
    (shop_model_data.price_dollars.to_f + shop_model_data.price_cents.to_f / 100).round(2)
  end

  def get_products_amount(product_id)
    get_position_data(product_id)["amount"]
  end

  def get_products_price(shop_model_data)
    get_product_price(shop_model_data) * get_products_amount(shop_model_data.product_id)
  end

  def get_overall_value
    if @overall_value.to_i < 1
      overall_value = 0.0
      products_ids = get_product_ids
      db_shops = Shop.unscoped.where(product_id: products_ids, retailer_id: retailer.id)
      db_shops.each do |db_shop|
        overall_value += get_products_price(db_shop)
      end
      @overall_value = overall_value.round(2)
    else
      @overall_value
    end
  end

  def get_over_value
    if @over_all_value.to_i < 1
      overall_value = 0.0
      products_ids = get_product_ids
      db_shops = Shop.unscoped.where(product_id: products_ids, retailer_id: retailer.id).includes(:categories, :subcategories)
      db_shops.each do |db_shop|
        cat = db_shop.categories.map {|c| c.current_tags }.flatten
        sub_cat = db_shop.subcategories.map {|c| c.current_tags }.flatten
        pg_18 = Category.tags[:pg_18]

        unless (cat.include? pg_18) or (sub_cat.include? pg_18)
          overall_value += get_products_price(db_shop)
        end
      end
      @over_all_value = overall_value.round(2)
    else
      @over_all_value
    end
  end

  def get_promocode_value
    overall_value = 0.0
    brands_ids = promotion_code.all_brands ? Brand.all.ids : promotion_code.brands.ids
    db_shops = Shop.unscoped.where(product_id: Product.unscoped.where(id: get_product_ids, brand_id: brands_ids), retailer_id: retailer.id)

    db_shops.each do |db_shop|
      overall_value += get_products_price(db_shop)
    end
    overall_value += service_fee.to_f + delivery_fee.to_f + rider_fee.to_f
    overall_value.round(2)
  end

  def cal_estd_dlvry_at
    if week.to_i > 0
      @cal_estd_dlvry_at ||= delivery_slot.calculate_estd_delivery(Time.now, week)
    else
      @cal_estd_dlvry_at ||= delivery_slot.calculate_estimated_delivery_at(Time.now)
    end
  end

  def retailer_has_payment_type
    errors.add(:payment_type_id, "Retailer do not consider this type of payment!") if RetailerHasAvailablePaymentType.find_by(retailer_id: retailer_id, available_payment_type_id: payment_type_id).nil?
  end

  def order_value_is_enough
    errors.add(:order_value_is_not_enough, "Order value is not enough") if delivery_fee.to_f == 0 && get_over_value < retailer.delivery_zones.with_point(shopper_address.lonlat.to_s).maximum('retailer_delivery_zones.min_basket_value').to_f
  end

  def location_is_covered
    errors.add(:location_is_not_covered, "Location is not covered by El Grocer") unless retailer.in_delivery_zones?(shopper_address)
  end

  def promocode_invalid
    errors.add(:promocode_is_valid, 'Invalid promotion code') if realization_id.present? && (!promotion_code.can_be_used?(shopper_id, retailer_id) || !accepted_promocode)
  end

  def retailer_is_opened
    errors.add(:retailer_is_opened, 'Shop must be open to create order') unless delivery_slot_id.present? || retailer.is_opened? && !retailer.is_schedule_closed?(shopper_address)
  end

  def promocode_invalid_brands
    if realization_id.present? && promotion_code
      promo_threshold = SystemConfiguration.find_by(key: 'promo_threshold')
      # min_value = [promotion_code.min_basket_value.to_f, promotion_code.value_cents.to_f / 100.0].max
      errors.add(:promotion_invalid_brands, 'Value order isnt enough to use promocode.') if get_promocode_value < (promotion_code.min_basket_value.to_f - promo_threshold&.value.to_i)
    end
  end

  def wallet_amount_is_enough
    errors.add(:wallet_amount_is_not_enough, "Wallet amount is not enough") if shopper.wallet_total < wallet_amount_paid
  end

  def delivery_slot_exists
    errors.add(:delivery_slot_id, 'DeliverySlot does not exist') if delivery_slot_id.present? && !delivery_slot.present?
  end

  def delivery_slot_invalid
    unless order.delivery_slot_id == delivery_slot_id and (week.to_i == 0 or (order.estimated_delivery_at + 1.day).strftime('%V').to_i == week.to_i)
      reminder_hours = retailer.schedule_order_reminder_hours
      skip_hours = retailer.delivery_slot_skip_hours
      errors.add(:delivery_slot_invalid, 'Invalid Delivery Slot') if delivery_slot.present? && cal_estd_dlvry_at < Time.now
    end
  end

  # def delivery_slot_orders_limit
  #   errors.add(:delivery_slot_orders_limit, "Sorry! Someone else just snatched that delivery slot. Please select another.") if delivery_slot.present? && delivery_slot.orders_limit > 0 && delivery_slot.orders.where('date(estimated_delivery_at) = ? and status_id != 4', cal_estd_dlvry_at.to_date).count >= delivery_slot.orders_limit
  # end

  def products_amount
    sum = 0
    products.each do |prod|
      sum += prod["amount"].to_i
    end
    sum.to_i
  end

  # def orders_products_amount
  #   @amount ||= delivery_slot.orders.where('date(estimated_delivery_at) = ? and status_id != 4', cal_estd_dlvry_at.to_date).includes(:order_positions).sum(:amount).to_i
  # end

  def ds_limits_and_products
    # @ds_limits_and_products ||= DeliverySlot.joins("join (SELECT SUM(products_limit)*MIN(products_limit)/GREATEST(MIN(products_limit),1) total_limit, SUM(products_limit_margin) total_margin, SUM(orders_limit)*MIN(orders_limit)/GREATEST(MIN(orders_limit),1) total_orders_limit, start dsstart, day dsday FROM delivery_slots, retailer_delivery_zones sub_rdz WHERE retailer_delivery_zone_id = sub_rdz.id AND sub_rdz.retailer_id = #{retailer.id} group by start, day) AS totals on totals.dsstart = delivery_slots.start and totals.dsday = delivery_slots.day")
    #                                 .joins("join delivery_slots ds on ds.start = delivery_slots.start and ds.day = delivery_slots.day").joins("join retailer_delivery_zones rdz on rdz.id = ds.retailer_delivery_zone_id and rdz.retailer_id = #{retailer.id}")
    #                                 .joins("left outer join orders on orders.delivery_slot_id = ds.id and status_id != 4 and date(estimated_delivery_at) = '#{cal_estd_dlvry_at}'").joins("left outer join order_positions on order_positions.order_id = orders.id")
    #                                 .where(id: delivery_slot_id).select("delivery_slots.*, coalesce(sum(order_positions.amount),0) AS total_products, totals.total_limit, totals.total_margin, count(distinct orders.id) AS total_orders, totals.total_orders_limit").group("delivery_slots.id, totals.total_limit, totals.total_margin, totals.total_orders_limit").first
    @ds_limits_and_products ||= DeliverySlot.get_slot_info(delivery_slot_id, retailer.id, cal_estd_dlvry_at)
  end

  def delivery_slot_products_limit
    unless order.delivery_slot_id == delivery_slot_id and (week.to_i == 0 or (order.estimated_delivery_at + 1.day).strftime('%V').to_i == week.to_i)
      errors.add(:delivery_slot_products_limit, I18n.t("errors.slot_filled")) if delivery_slot.present? and (ds_limits_and_products.blank? or ((ds_limits_and_products.total_limit > 0 and ((ds_limits_and_products.total_products + products_amount) > (ds_limits_and_products.total_limit + ds_limits_and_products.total_margin)) and ((ds_limits_and_products.total_products/(ds_limits_and_products.total_limit * 1.0)) > 0.7)) or (ds_limits_and_products.total_orders_limit > 0 and ds_limits_and_products.total_orders >= ds_limits_and_products.total_orders_limit)))
    end
    # errors.add(:delivery_slot_products_limit, "Sorry! Someone else just snatched that delivery slot. Please select another.") if delivery_slot.present? && delivery_slot.products_limit > 0 && ((orders_products_amount + products_amount - OrderPosition.where(order_id: order.id).sum(:amount).to_i) > (delivery_slot.products_limit + delivery_slot.products_limit_margin)) and ((orders_products_amount/(delivery_slot.products_limit * 1.0)) > 0.7)
  end

  def retailer_delivery_type_invalid
    errors.add(:retailer_delivery_type_invalid, "Oops! This time slot is taken now, please select another.") if (retailer_delivery_zone.instant? and delivery_slot.present?) or (retailer_delivery_zone.schedule? and delivery_slot.blank?)
  end

  def order_in_edit
    if order and ![-1,8].include?(order.status_id)
      if order.status_id == 4
        errors.add(:order_is_cancelled, "Order is cancelled")
      elsif order.status_id != 8
        errors.add(:order_not_in_edit, "Order not in edit")
      end
    end
  end
end
