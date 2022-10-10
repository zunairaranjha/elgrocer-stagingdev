# frozen_string_literal: true

module Concerns
  module OrderHelper
    extend Grape::API::Helpers

    def order
      @order ||= Order.find_by_id(params[:order_id])
    end

    def order_params
      _params = {
        retailer_id: retailer.id,
        shopper_id: current_shopper.id,
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
        shopper_phone_number: current_shopper.phone_number,
        shopper_name: current_shopper.name,
        payment_type_id: payment_type.id,
        shopper_note: params[:shopper_note],
        service_fee: retailer_has_service.service_fee.to_f.round(2),
        language: params[:locale],
        vat: params[:vat],
        retailer_service_id: retailer_has_service.retailer_service_id,
        app_version: request.headers['App-Version'] || 'WEB'
      }

      if retailer_has_service.retailer_service_id == 1
        _params[:shopper_phone_number] = shopper_address.phone_number || current_shopper.phone_number
        _params[:shopper_name] = shopper_address.shopper_name || current_shopper.name
        _params[:shopper_address_id] = shopper_address.id
        _params[:shopper_address_name] = shopper_address.address_name
        _params[:shopper_address_area] = shopper_address.area
        _params[:shopper_address_street] = shopper_address.street
        _params[:shopper_address_building_name] = shopper_address.building_name
        _params[:shopper_address_apartment_number] = shopper_address.apartment_number
        _params[:shopper_address_longitude] = shopper_address.longitude
        _params[:shopper_address_latitude] = shopper_address.latitude
        _params[:shopper_address_location_address] = shopper_address.location_address
        _params[:shopper_address_type_id] = shopper_address.address_type_id
        _params[:shopper_address_location_id] = shopper_address.location_id
        _params[:shopper_address_location_name] = shopper_address.location_name
        _params[:shopper_address_additional_direction] = shopper_address.additional_direction
        _params[:shopper_address_floor] = shopper_address.floor
        _params[:shopper_address_house_number] = shopper_address.house_number
        # _params[:delivery_fee] = retailer_delivery_zone.delivery_fee.to_f.round(2)
        _params[:rider_fee] = retailer_delivery_zone.rider_fee.to_f.round(2)
        _params[:retailer_delivery_zone_id] = retailer_delivery_zone.id
      end
      _params[:estimated_delivery_at] = delivery_slot.present? ? params[:estimate_delivery_time].to_time : Time.now + 1.hour
      _params[:delivery_type_id] = delivery_slot.present? ? 1 : 0 #0=instant,1=schedule
      _params[:device_type] = params[:device_type] || current_shopper.device_type
      _params
    end

    def create_order
      # order_params[:status_id] = payment_type.id == 3 ? -1 : 0
      _order = Order.find_by(retailer_id: retailer.id, status_id: -1, shopper_id: current_shopper.id)
      order_params[:date_time_offset] = request.headers['Datetimeoffset']
      if _order
        clear(_order.id)
        _order.attributes = order_params.compact
        _order.created_at = Time.now
      else
        _order = Order.new(order_params.compact)
      end
      _order.status_id = payment_type.id == 3 ? -1 : 0
      _order.delivery_slot_id = delivery_slot.present? ? delivery_slot.id : nil
      _order.min_basket_value = retailer_has_service.retailer_service_id == 1 ? retailer_delivery_zone.min_basket_value : retailer_has_service.min_basket_value
      _order.delivery_fee = _order.min_basket_value > total_value_of_order ? retailer_delivery_zone.delivery_fee.to_f.round(2) : 0
      _order.total_value = total_value_of_order
      _order.save!
      _order
    end

    def update_order!
      order.status_id = (order.payment_type_id == 3 and order.payment_type_id == payment_type.id and order.status_id == -1) ? -1 : 0
      if order.payment_type_id == 3 and order.payment_type_id != payment_type.id and order.card_detail.present?
        PayfortJob.perform_later('void_authorization', order, nil, order.merchant_reference, order.card_detail['auth_amount'].to_i / 100.0)
      elsif order.payment_type_id != 3 and payment_type.id == 3
        order.status_id = -1
      end
      order.attributes = order_params.compact
      order.delivery_slot_id = delivery_slot.present? ? delivery_slot.id : nil
      order.min_basket_value = retailer_has_service.retailer_service_id == 1 ? retailer_delivery_zone.min_basket_value : retailer_has_service.min_basket_value
      order.delivery_fee = order.min_basket_value > total_value_of_order ? retailer_delivery_zone.delivery_fee.to_f.round(2) : 0
      order.total_value = total_value_of_order
      order.save!
      order
    end

    def clear(order_id)
      OrderPosition.where(order_id: order_id).delete_all
    end

    def clear_order(order_id)
      clear(order_id)
      OrderSubstitution.where(order_id: order_id).delete_all
      PromotionCodeRealization.where(order_id: order_id).where.not(id: params[:promotion_code_realization_id]).update_all(retailer_id: nil, order_id: nil)
    end

    def create_positions!(order_id)
      new_positions = []
      db_products = get_products

      db_products.each do |pr|
        promotional_price = 0
        is_promotional = false
        shop_id = pr.shop_id
        price_currency = pr.price_currency
        price_cents = pr.price_cents
        price_dollars = pr.price_dollars

        if pr.shop_promotions.present?
          p_shop = pr.shop_promotions.first
          promotional_price = p_shop.price
          is_promotional = true
          price_currency = p_shop.price_currency
          price_dollars = p_shop.standard_price.to_i
          price_cents = ((p_shop.standard_price - price_dollars) * 100).round
          # if pr.is_promotional
          # end
        end
        # order of values should be (order_id,product_id ,amount ,was_in_shop ,product_barcode ,product_brand_name ,product_name ,product_description ,product_shelf_life ,product_size_unit ,product_country_alpha2 ,product_location_id ,product_category_name ,product_subcategory_name ,shop_price_cents ,shop_price_currency ,shop_id ,shop_price_dollars ,commission_value ,category_id ,subcategory_id ,brand_id ,is_promotional)
        new_positions.push("(#{order_id},#{pr.id},#{get_product_qty(pr.id)},#{true},'#{pr.barcode}','#{pr.brand&.name || 'Other'}','#{pr.name}','#{pr.description}',#{pr.shelf_life || 'NULL'},'#{pr.size_unit}','#{pr.country_alpha2}',#{pr.location_id || 'NULL'},'#{pr.categories.first&.name || 'Other'}','#{pr.subcategories.first&.name || 'Other'}',#{price_cents.to_i},'#{price_currency || 'AED'}',#{shop_id || 'NULL'},#{price_dollars.to_i},#{retailer.commission_value.to_f},#{pr.categories.first&.id || 'NULL'},#{pr.subcategories.first&.id || 'NULL'},#{pr.brand_id || 'NULL'},#{is_promotional},#{promotional_price},#{request.headers['Datetimeoffset'] || 'NULL'})".gsub("''", 'NULL').gsub(/(?<=\p{Alnum})'(?=\p{Alnum})/, "''").gsub(/(?<=\p{Alnum})' (?=\p{Alnum})/, "'' ").gsub(/(?<=\p{Alnum}) '(?=\p{Alnum})/, " ''"))
      end

      OrderPosition.transaction do
        ActiveRecord::Base.connection.execute("INSERT INTO order_positions (order_id,product_id ,amount ,was_in_shop ,product_barcode ,product_brand_name ,product_name ,product_description ,product_shelf_life ,product_size_unit ,product_country_alpha2 ,product_location_id ,product_category_name ,product_subcategory_name ,shop_price_cents ,shop_price_currency ,shop_id ,shop_price_dollars ,commission_value ,category_id ,subcategory_id ,brand_id ,is_promotional, promotional_price, date_time_offset) VALUES #{new_positions.join(',')}")
      end
    end

    def create_collection_detail(order_id)
      OrderCollectionDetail.create(order_id: order_id, pickup_location_id: pickup_location.id, vehicle_detail_id: vehicle_detail.id, collector_detail_id: params[:collector_detail_id])
    end

    def update_collection_detail(order_id)
      order_collection_detail = OrderCollectionDetail.find_or_initialize_by(order_id: order_id)
      order_collection_detail.pickup_location_id = pickup_location.id
      order_collection_detail.vehicle_detail_id = vehicle_detail.id
      order_collection_detail.collector_detail_id = params[:collector_detail_id]
      order_collection_detail.save
    end

    def delivery_requirements
      error!(CustomErrors.instance.shopper_address_id_missing, 421) unless params[:shopper_address_id]
      error!(CustomErrors.instance.shopper_address_not_found, 421) unless shopper_address
      error!(CustomErrors.instance.location_not_covered_retailer, 421) unless retailer_delivery_zone
      error!(CustomErrors.instance.retailer_not_open_for_order, 421) unless retailer_opened
      error!(CustomErrors.instance.value_not_enough, 421) if delivery_value_not_enough
    end

    def c_n_c_requirements
      error!(CustomErrors.instance.value_not_enough, 421) if cc_value_not_enough
      error!(CustomErrors.instance.collector_not_found, 421) if params[:collector_detail_id] and collector_detail.blank?
      error!(CustomErrors.instance.vehicle_not_found, 421) if params[:vehicle_detail_id] and vehicle_detail.blank?
      error!(CustomErrors.instance.pickup_location_not_found, 421) if params[:pickup_location_id] and pickup_location.blank?
    end

    def delivery_slot_validation
      error!(CustomErrors.instance.delivery_type_invalid, 421) if retailer_has_service.retailer_service_id == 2 and ((retailer_has_service.instant? and delivery_slot.present?) or (retailer_has_service.schedule? and delivery_slot.blank?))
      error!(CustomErrors.instance.delivery_type_invalid, 421) if retailer_has_service.retailer_service_id == 1 and ((retailer_delivery_zone.instant? and delivery_slot.present?) or (retailer_delivery_zone.schedule? and delivery_slot.blank?))
      error!(CustomErrors.instance.delivery_slot_not_exits, 421) if params[:delivery_slot_id] and delivery_slot.blank?
      if request.headers['User-Agent'].to_s =~ /ElGrocerShopper/ and params[:week] and delivery_slot.present?
        params[:estimate_delivery_time] = delivery_slot.calculate_estd_delivery(params[:estimate_delivery_time].to_time, params[:week])
      end
      if delivery_slot.present? and params[:estimate_delivery_time]
        case retailer_has_service.retailer_service_id
        when 1
          if params[:estimate_delivery_time].to_time < (Time.now + retailer_delivery_zone.delivery_slot_skip_time.second)
            error!(CustomErrors.instance.delivery_slot_invalid, 421)
          end
        when 2
          if params[:estimate_delivery_time].to_time < (Time.now + retailer_has_service.delivery_slot_skip_time.second)
            error!(CustomErrors.instance.delivery_slot_invalid, 421)
          end
        end
      end
    end

    def create_slot_validation
      delivery_slot_validation
      if retailer_has_service.retailer_service_id == 1 and delivery_slot.present? and
        ((ds_limit.total_limit.positive? and ((ds_limit.total_products + products_amount) > (ds_limit.total_limit + ds_limit.total_margin)) and ((ds_limit.total_products / (ds_limit.total_limit * 1.0)) > 0.7)) or
          (ds_limit.total_orders_limit.positive? and ds_limit.total_orders >= ds_limit.total_orders_limit))
        error!(CustomErrors.instance.slot_filled, 421)
      elsif retailer_has_service.retailer_service_id == 2 and delivery_slot.present? and
        ((ds_cc_limit.products_limit.positive? and ((ds_cc_limit.total_products + products_amount) > (ds_cc_limit.products_limit + ds_cc_limit.products_limit_margin)) and ((ds_cc_limit.total_products / (ds_cc_limit.products_limit * 1.0)) > 0.7)) or
          (ds_cc_limit.orders_limit.positive? and ds_cc_limit.total_orders >= ds_cc_limit.orders_limit))
        error!(CustomErrors.instance.slot_filled, 421)
      end
    end

    def update_slot_validation
      delivery_slot_validation
      if retailer_has_service.retailer_service_id == 1 and delivery_slot.present? and order.delivery_slot_id != delivery_slot.id and
        ((ds_limit.total_limit.positive? and ((ds_limit.total_products + products_amount) > (ds_limit.total_limit + ds_limit.total_margin)) and ((ds_limit.total_products / (ds_limit.total_limit * 1.0)) > 0.7)) or
          (ds_limit.total_orders_limit.positive? and ds_limit.total_orders >= ds_limit.total_orders_limit))
        error!(CustomErrors.instance.slot_filled, 421)
      elsif retailer_has_service.retailer_service_id == 2 and delivery_slot.present? and order.delivery_slot_id != delivery_slot.id and
        ((ds_cc_limit.products_limit.positive? and ((ds_cc_limit.total_products + products_amount) > (ds_cc_limit.products_limit + ds_cc_limit.products_limit_margin)) and ((ds_cc_limit.total_products / (ds_cc_limit.products_limit * 1.0)) > 0.7)) or
          (ds_cc_limit.orders_limit.positive? and ds_cc_limit.total_orders >= ds_cc_limit.orders_limit))
        error!(CustomErrors.instance.slot_filled, 421)
      end
    end

    def validate_promotion_code
      error!(CustomErrors.instance.invalid_promo, 421) if invalid_promotion_code
      error!(CustomErrors.instance.promo_expired, 421) if promo_exist == 1 and !promotion_code.expired_now?
      error!(CustomErrors.instance.max_allowed_realization_exceed, 421) if promo_exist == 1 and !promotion_code.proper_number_of_realizations?
      error!(CustomErrors.instance.promo_not_for_retailer, 421) if promo_exist == 1 and !promotion_code.all_retailers and !promotion_code.for_retailer?(retailer.id)
      error!(CustomErrors.instance.promo_already_used, 421) if promo_exist == 1 and promotion_code.used_by_shopper?(current_shopper.id, retailer.id)
      promo_invalid_brands
      error!(CustomErrors.instance.payment_invalid_for_promo, 421) if promo_exist == 1 and (!(promotion_code.available_payment_types.ids.include? payment_type.id) || !accepted_promocode)
      error!(CustomErrors.instance.promo_order_limit(promotion_code.order_limit), 421) if promo_exist == 1 and !promotion_code.order_limit_not_exceed(current_shopper.id)
      error!(CustomErrors.instance.promo_not_for_shopper, 421) if promo_exist == 1 and !promotion_code.for_shopper?(current_shopper.id)
      if retailer_has_service.retailer_service_id == 1
        error!(CustomErrors.instance.promo_only_for_delivery, 421) if promo_exist == 1 and !promotion_code.for_service?(retailer_has_service.retailer_service_id)
      else
        error!(CustomErrors.instance.promo_only_for_cnc, 421) if promo_exist == 1 and !promotion_code.for_service?(retailer_has_service.retailer_service_id)
      end
    end

    def retailer
      @retailer ||= Retailer.find_by(id: params[:retailer_id], is_active: true)
    end

    def retailer_has_service
      @retailer_has_service ||= RetailerHasService.find_by(retailer_id: retailer.id, retailer_service_id: params[:retailer_service_id], is_active: true)
    end

    def payment_type
      @payment_type ||= AvailablePaymentType.joins(:retailer_has_available_payment_types)
                                            .where(retailer_has_available_payment_types: { retailer_id: retailer.id, retailer_service_id: retailer_has_service.retailer_service_id, available_payment_type_id: params[:payment_type_id] })
                                            .distinct.first
    end

    def shopper_online_payment_block
      current_shopper.is_blocked && payment_type.id == 3
    end

    def shopper_address
      @shopper_address ||= ShopperAddress.find_by(shopper_id: current_shopper.id, id: params[:shopper_address_id])
    end

    def retailer_delivery_zone
      @retailer_delivery_zone ||= retailer.retailer_delivery_zone_with(shopper_address)
    end

    def retailer_opened
      params[:delivery_slot_id].present? || retailer.is_opened? && RetailerOpeningHour.not_schedule_close?(retailer_delivery_zone&.id)
    end

    def delivery_value_not_enough
      retailer_delivery_zone.delivery_fee.to_f.zero? && value_of_products < retailer_delivery_zone.min_basket_value.to_f
    end

    def cc_value_not_enough
      value_of_products < retailer_has_service.min_basket_value.to_f
    end

    def get_product_ids
      @product_ids ||= params[:products].map { |product| product[:product_id] }
    end

    def total_value_of_order
      return @value_of_order unless @value_of_order.to_i < 1

      @value_of_order = 0.0
      _shops = get_products
      _shops.each do |shop|
        @value_of_order += get_product_price(shop)
      end
      @value_of_order.round(2)
    end

    def value_of_products
      return @value_of_products unless @value_of_products.to_i < 1

      @value_of_products = 0.0
      db_shops = get_products
      db_shops.each do |shop|
        cat = shop.categories.map(&:current_tags).flatten
        sub_cat = shop.subcategories.map(&:current_tags).flatten
        pg_18 = Category.tags[:pg_18]
        @value_of_products += get_product_price(shop) unless (cat.include? pg_18) or (sub_cat.include? pg_18)
      end
      @value_of_products = @value_of_products.round(2)
    end

    def get_promo_value
      overall_value = brand_products_value
      overall_value += service_fees
      overall_value.round(2)
    end

    def brand_products_value
      return @brand_products_value unless @brand_products_value.to_i < 1

      @brand_products_value =
        if promotion_code.all_brands
          total_value_of_order
        else
          brand_ids = promotion_code.brands.ids
          overall_value = 0.0
          db_shops = get_products.select { |p| brand_ids.include? p.brand_id }

          db_shops.each do |db_shop|
            overall_value += get_product_price(db_shop)
          end
          overall_value.round(2)
        end
    end

    def discount_value
      if promotion_code.percentage_off.to_f.positive?
        [(brand_products_value * promotion_code.percentage_off.to_f).floor, promotion_code.value_cents].min
      else
        promotion_code.value_cents
      end
    end

    def get_product_qty(product_id)
      params[:products].detect { |prod| prod[:product_id] == product_id }[:amount]
    end

    def get_shop_price(product)
      if product.shop_promotions.present?
        shop = product.shop_promotions.first
        shop.price
      else
        (product.price_dollars.to_f + product.price_cents.to_f / 100).round(2)
      end
    end

    def get_product_price(product)
      get_shop_price(product) * get_product_qty(product.id)
    end

    def products_amount
      params[:products].map { |h| h[:amount] }.sum
    end

    def invalid_promotion_code
      params[:promotion_code_realization_id] and promo_exist.zero?
    end

    def promo_realization
      @promo_realization ||= PromotionCodeRealization.find_by(id: params[:promotion_code_realization_id])
    end

    def promotion_code
      @promotion_code ||= promo_realization&.promotion_code
    end

    def promo_exist
      @promo_exist ||= promotion_code.nil? ? 0 : 1
    end

    def service_fees
      @service_fees ||= retailer_has_service.service_fee + delivery_fees
    end

    def delivery_fees
      delivery_fee = 0
      if retailer_has_service.retailer_service_id == 1
        delivery_fee = retailer_delivery_zone.rider_fee.to_f + (
          if (total_value_of_order + retailer_has_service.service_fee) < retailer_delivery_zone.min_basket_value
            retailer_delivery_zone.delivery_fee.to_f
          else
            0
          end)
      end
      delivery_fee
    end

    def promo_invalid_brands
      if promo_exist == 1
        promo_threshold = SystemConfiguration.find_by(key: 'promo_threshold')
        # min_value = [promotion_code.min_basket_value.to_f, promotion_code.value_cents.to_f / 100.0].max
        if get_promo_value < (promotion_code.min_basket_value.to_f - promo_threshold&.value.to_i)
          brand_names = I18n.locale.to_s.downcase.eql?('en') ? promotion_code.brands.limit(5).pluck('name') * (', ') : promotion_code.brands.limit(5).pluck('name_ar') * (', ')
          error!(CustomErrors.instance.promo_invalid_brands(brand_names, promotion_code.min_basket_value.to_f), 421)
        end
      end
    end

    def delivery_slot
      @delivery_slot ||= DeliverySlot.find_by(id: params[:delivery_slot_id], is_active: true, retailer_service_id: retailer_has_service.retailer_service_id) if params[:delivery_slot_id]
    end

    def ds_limit
      @ds_limits ||= DeliverySlot.get_slot_info(delivery_slot.id, retailer.id, params[:estimate_delivery_time].to_time)
    end

    def ds_cc_limit
      @ds_cc_limits ||= DeliverySlot.get_cc_slot_info(delivery_slot.id, params[:estimate_delivery_time].to_time)
    end

    def collector_detail
      @collector_detail ||= CollectorDetail.find_by_id(params[:collector_detail_id])
    end

    def vehicle_detail
      @vehicle_detail ||= VehicleDetail.find_by_id(params[:vehicle_detail_id])
    end

    def pickup_location
      @pickup_location ||= PickupLocation.find_by(id: params[:pickup_location_id], retailer_id: retailer.id)
    end

    # def non_promotion_products
    #   return @products if @products
    #   @products = Product.joins(:shops).includes(:brand, :subcategories, :categories)
    #                      .select("products.*, shops.id AS shop_id, shops.price_cents, shops.price_dollars, shops.price_currency, shops.promotion_only")
    #                      .where(id: get_product_ids, shops: { retailer_id: retailer.id, promotion_only: false })
    #   ActiveRecord::Associations::Preloader.new.preload(@products, :shop_promotions, { where: ("shop_promotions.retailer_id = #{retailer.id} AND #{delivery_time} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: [:end_time, :start_time] })
    #   @products
    # end

    # def promotion_product
    #   return @promotion_products if @promotion_products
    #   @promotion_products = Product.joins(:shop_promotions, :shops).includes(:brand, :subcategories, :categories).where(id: get_product_ids, shops: { retailer_id: retailer.id, is_promotional: true, promotion_only: true })
    #                                .select("products.*, shops.id AS shop_id, shops.price_cents, shops.price_dollars, shops.price_currency, shops.promotion_only")
    #                                .where("shop_promotions.retailer_id = ? AND ? BETWEEN shop_promotions.start_time AND shop_promotions.end_time", retailer.id, delivery_time)
    #   ActiveRecord::Associations::Preloader.new.preload(@promotion_products, :shop_promotions, { where: ("shop_promotions.retailer_id = #{retailer.id} AND #{delivery_time} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: [:end_time, :start_time] })
    #   @promotion_products
    # end

    def get_products
      return @all_products if @all_products

      @all_products = Product.products_with_shops(get_product_ids, retailer.id, delivery_time)
      ActiveRecord::Associations::Preloader.new.preload(@all_products, [:brand, :categories, :subcategories])
      ActiveRecord::Associations::Preloader.new.preload(@all_products, :shop_promotions, { where: ("shop_promotions.retailer_id = #{retailer.id} AND #{delivery_time} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: [:end_time, :start_time] })
      @all_products
    end

    def accepted_promocode
      @accepted_promocode ||= RetailerHasAvailablePaymentType.where(retailer_id: retailer.id, available_payment_type_id: payment_type.id, accept_promocode: true, retailer_service_id: retailer_has_service.retailer_service_id).exists?
    end

    def delivery_time
      @delivery_time ||= ((params[:estimate_delivery_time] && params[:estimate_delivery_time] || Time.now).to_time.utc.to_f * 1000).floor
    end
  end
end
