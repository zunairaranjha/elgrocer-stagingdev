# frozen_string_literal: true

module Concerns
  module CreateUpdateOrderHelper
    extend Grape::API::Helpers

    def create_validations
      request_validation
      create_slot_validation
      service_validation
      validate_promotion_code
    end

    def update_validation
      error!(CustomErrors.instance.order_not_found, 421) unless order
      request_validation
      error!(CustomErrors.instance.shopper_not_have_order, 421) unless order.shopper_id == current_shopper.id
      error!(CustomErrors.instance.order_not_in_edit, 421) unless [-1, 8].include?(order.status_id)
      update_slot_validation
      service_validation
      validate_promotion_code
    end

    def request_validation
      I18n.locale = :en
      error!(CustomErrors.instance.not_allowed, 421) unless current_shopper
      error!(CustomErrors.instance.products_empty, 421) if params[:products].empty?
      error!(CustomErrors.instance.retailer_not_found, 421) unless retailer
      error!(CustomErrors.instance.retailer_not_have_service, 421) unless retailer_has_service
      error!(CustomErrors.instance.payment_type_invalid, 421) unless payment_type
      error!(CustomErrors.instance.fraudster, 421) if current_shopper.is_blocked && params[:payment_type_id] == 3
    end

    def service_validation
      case params[:retailer_service_id]
      when 1
        delivery_requirements
      when 2
        c_n_c_requirements
      end
    end

    def order
      @order ||= Order.find_by_id(params[:order_id])
    end

    def order_params
      _params = {
        retailer_id: retailer.id, shopper_id: current_shopper.id, retailer_phone_number: retailer.phone_number,
        retailer_company_name: retailer.company_name, retailer_opening_time: retailer.opening_time,
        retailer_company_address: retailer.company_address, retailer_location_id: retailer.location_id,
        retailer_location_name: retailer.location_name, retailer_contact_person_name: retailer.contact_person_name,
        retailer_street: retailer.street, retailer_building: retailer.building, retailer_apartment: retailer.apartment,
        retailer_flat_number: retailer.flat_number, retailer_contact_email: retailer.contact_email,
        retailer_delivery_range: retailer.delivery_range, shopper_phone_number: current_shopper.phone_number,
        shopper_name: current_shopper.name, payment_type_id: params[:payment_type_id], shopper_note: params[:shopper_note],
        service_fee: retailer_has_service.service_fee.to_f.round(2), language: request.headers['Locale'] || params[:locale], vat: params[:vat],
        retailer_service_id: params[:retailer_service_id], app_version: request.headers['App-Version'] || 'WEB',
        date_time_offset: request.headers['Datetimeoffset']
      }
      if params[:retailer_service_id] == 1
        _params[:shopper_phone_number] = shopper_address.phone_number || current_shopper.phone_number
        _params[:shopper_name] = shopper_address.shopper_name || current_shopper.name
        _params[:shopper_address_id] = shopper_address.id; _params[:shopper_address_name] = shopper_address.address_name
        _params[:shopper_address_area] = shopper_address.area; _params[:shopper_address_street] = shopper_address.street
        _params[:shopper_address_building_name] = shopper_address.building_name
        _params[:shopper_address_apartment_number] = shopper_address.apartment_number
        _params[:shopper_address_longitude] = shopper_address.longitude
        _params[:shopper_address_latitude] = shopper_address.latitude; _params[:shopper_address_floor] = shopper_address.floor
        _params[:shopper_address_location_address] = shopper_address.location_address
        _params[:shopper_address_type_id] = shopper_address.address_type_id
        _params[:shopper_address_location_id] = shopper_address.location_id
        _params[:shopper_address_location_name] = shopper_address.location_name
        _params[:shopper_address_additional_direction] = shopper_address.additional_direction
        _params[:shopper_address_house_number] = shopper_address.house_number
        _params[:rider_fee] = retailer_delivery_zone.rider_fee.to_f.round(2)
        _params[:retailer_delivery_zone_id] = retailer_delivery_zone.id
      end
      _params[:estimated_delivery_at] = delivery_slot.present? ? delivery_slot.slot_start.to_time : Time.now + 1.hour
      _params[:delivery_type_id] = delivery_slot.present? ? 1 : 0 # 0=instant,1=schedule
      _params[:device_type] = params[:device_type] || current_shopper.device_type
      _params
    end

    def create_order
      _order = Order.find_by(retailer_id: retailer.id, status_id: -1, shopper_id: current_shopper.id)
      if _order
        clear(_order.id)
        _order.attributes = order_params.compact
        _order.created_at = Time.now
      else
        _order = Order.new(order_params.compact)
      end
      _order.status_id = params[:payment_type_id] == 3 ? -1 : 0
      _order.delivery_slot_id = delivery_slot.present? ? delivery_slot.id : nil
      _order.min_basket_value = params[:retailer_service_id] == 1 ? retailer_delivery_zone.min_basket_value : retailer_has_service.min_basket_value
      _order.delivery_fee = _order.min_basket_value > total_value_of_order ? retailer_delivery_zone.delivery_fee.to_f.round(2) : 0
      _order.total_value = total_value_of_order
      _order.platform_type = request.headers['Loyalty-Id'].present? ? 1 : 0
      _order.save!
      _order
    end

    def update_order!
      is_online = order.payment_type_id == 3 && order.payment_type_id == params[:payment_type_id]
      order.status_id = (is_online && order.status_id == -1) ? -1 : 0
      if order.payment_type_id == 3 && order.payment_type_id != params[:payment_type_id] && order.card_detail.present?
        if order.card_detail['ps'].to_s.eql?('adyen')
          AdyenJob.perform_later('void_authorization', order, order.merchant_reference)
        else
          PayfortJob.perform_later('void_authorization', order, nil, order.merchant_reference, order.card_detail['auth_amount'].to_i / 100.0)
        end
        order.credit_card_id = nil
      elsif params[:payment_type_id] == 3 && order.payment_type_id != 3
        order.status_id = -1
      end

      smiles_transactions_to_rollback(order) if order.payment_type_id == 4 && order.payment_type_id != params[:payment_type_id]

      # update_order_smiles_points(order)
      # if order.payment_type_id == 4 && order.payment_type_id == params[:payment_type_id]
      #   update_debit_smiles_points(order, order.total_price)
      # elsif order.payment_type_id == 4 && order.payment_type_id != params[:payment_type_id]
      #   smile_points_rollback(order)
      # elsif order.payment_type_id != 4 && params[:payment_type_id] == 4
      #   debit_smiles_points(order)
      # end
      order.attributes = order_params.compact
      order.delivery_slot_id = delivery_slot.present? ? delivery_slot.id : nil
      order.min_basket_value = params[:retailer_service_id] == 1 ? retailer_delivery_zone.min_basket_value : retailer_has_service.min_basket_value
      order.delivery_fee = order.min_basket_value > total_value_of_order ? retailer_delivery_zone.delivery_fee.to_f.round(2) : 0
      order.total_value = total_value_of_order
      if order.total_value > order.total_value_was && is_online && params[:same_card]
        # AdyenJob.perform_later('auth_amount_changed', order)
        order.status_id = -1
      elsif is_online && order.card_detail.present? && order.card_detail['ps'].to_s.eql?('adyen') && !params[:same_card]
        AdyenJob.perform_later('void_authorization', order, order.merchant_reference)
        order.status_id = -1
      end
      order.save!
      update_debit_smiles_points(order, order.total_price) if order.payment_type_id == 4
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
        promotional_price = 0; is_promotional = false; shop_id = pr.shop_id; price_currency = pr.price_currency
        price_cents = pr.price_cents; price_dollars = pr.price_dollars
        if pr.shop_promotions.present?
          p_shop = pr.shop_promotions.first; promotional_price = p_shop.price; is_promotional = true
          price_currency = p_shop.price_currency; price_dollars = p_shop.standard_price.to_i
          price_cents = ((p_shop.standard_price - price_dollars) * 100).round
        end
        op = OrderPosition.new(order_id: order_id, product_id: pr.id, amount: get_product_qty(pr.id), product_name: pr.name)
        op.product_barcode = pr.barcode; op.product_brand_name = pr.brand&.name || 'Other'; op.product_name = pr.name
        op.product_description = pr.description; op.product_shelf_life = pr.shelf_life; op.product_size_unit = pr.size_unit
        op.product_country_alpha2 = pr.country_alpha2; op.product_location_id = pr.location_id; op.shop_price_cents = price_cents
        op.shop_price_currency = price_currency || 'AED'; op.shop_price_dollars = price_dollars; op.shop_id = shop_id
        op.product_category_name = pr.categories.first&.name || 'Other'; op.category_id = pr.categories.first&.id
        op.commission_value = retailer.commission_value.to_f; op.product_subcategory_name = pr.subcategories.first&.name || 'Other'
        op.subcategory_id = pr.subcategories.first&.id; op.brand_id = pr.brand_id; op.is_promotional = is_promotional
        op.promotional_price = promotional_price; op.date_time_offset = request.headers['Datetimeoffset']
        new_positions << op
        # order of values should be (order_id,product_id ,amount ,was_in_shop ,product_barcode ,product_brand_name ,product_name ,product_description ,product_shelf_life ,product_size_unit ,product_country_alpha2 ,product_location_id ,product_category_name ,product_subcategory_name ,shop_price_cents ,shop_price_currency ,shop_id ,shop_price_dollars ,commission_value ,category_id ,subcategory_id ,brand_id ,is_promotional)
        # new_positions.push("(#{order_id},#{pr.id},#{get_product_qty(pr.id)},#{true},'#{pr.barcode}','#{pr.brand&.name || 'Other'}','#{pr.name}','#{pr.description}',#{pr.shelf_life || 'NULL'},'#{pr.size_unit}','#{pr.country_alpha2}',#{pr.location_id || 'NULL'},'#{pr.categories.first&.name || 'Other'}','#{pr.subcategories.first&.name || 'Other'}',#{price_cents.to_i},'#{price_currency || 'AED'}',#{shop_id || 'NULL'},#{price_dollars.to_i},#{retailer.commission_value.to_f},#{pr.categories.first&.id || 'NULL'},#{pr.subcategories.first&.id || 'NULL'},#{pr.brand_id || 'NULL'},#{is_promotional},#{promotional_price},#{request.headers['Datetimeoffset'] || 'NULL'})".gsub("''", 'NULL').gsub(/(?<=\p{Alnum})'(?=\p{Alnum})/, "''").gsub(/(?<=\p{Alnum})' (?=\p{Alnum})/, "'' ").gsub(/(?<=\p{Alnum}) '(?=\p{Alnum})/, " ''"))
      end

      OrderPosition.transaction do
        # ActiveRecord::Base.connection.execute("INSERT INTO order_positions (order_id,product_id ,amount ,was_in_shop ,product_barcode ,product_brand_name ,product_name ,product_description ,product_shelf_life ,product_size_unit ,product_country_alpha2 ,product_location_id ,product_category_name ,product_subcategory_name ,shop_price_cents ,shop_price_currency ,shop_id ,shop_price_dollars ,commission_value ,category_id ,subcategory_id ,brand_id ,is_promotional, promotional_price, date_time_offset) VALUES #{new_positions.join(',')}")
        OrderPosition.import(new_positions)
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

    def promotion_on_order(order)
      if promo_realization.present? # && promotion_code.can_be_used?(shopper_id, retailer_id)
        promo_realization.order_id = order.id
        promo_realization.discount_value = discount_value
        promo_realization.retailer_id = order.retailer_id unless params[:payment_type_id] == 3
        promo_realization.save
      else
        PromotionCodeRealization.where(order_id: order.id).update_all(retailer_id: nil, order_id: nil)
      end
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
      error!(CustomErrors.instance.collector_not_found, 421) if params[:collector_detail_id] && collector_detail.blank?
      error!(CustomErrors.instance.vehicle_not_found, 421) if params[:vehicle_detail_id] && vehicle_detail.blank?
      error!(CustomErrors.instance.pickup_location_not_found, 421) if params[:pickup_location_id] && pickup_location.blank?
    end

    def delivery_slot_validation
      case params[:retailer_service_id]
      when 1
        params[:usid].present? ? is_instant?(retailer_delivery_zone) : is_schedule?(retailer_delivery_zone)
      when 2
        params[:usid].present? ? is_instant?(retailer_has_service) : is_schedule?(retailer_has_service)
      end
      error!(CustomErrors.instance.delivery_slot_not_exits, 421) if params[:usid].present? && slot_exits.zero?
      return unless slot_exits.positive? && delivery_slot.present?

      case params[:retailer_service_id]
      when 1
        valid_delivery_time(retailer_delivery_zone)
      when 2
        valid_delivery_time(retailer_has_service)
      end
    end

    def slot_limit_validate
      if params[:usid] && (delivery_slot.blank? || (delivery_slot.total_limit.positive? &&
        (delivery_slot.total_products + products_amount) > (delivery_slot.total_limit + delivery_slot.total_margin)))
        error!(CustomErrors.instance.slot_filled, 421)
      end
    end

    def create_slot_validation
      delivery_slot_validation
      slot_limit_validate
    end

    def update_slot_validation
      delivery_slot_validation
      slot_limit_validate if order.delivery_slot_id != delivery_slot&.id
    end

    def is_instant?(model)
      error!(CustomErrors.instance.delivery_type_invalid, 421) if model.instant?
    end

    def is_schedule?(model)
      error!(CustomErrors.instance.delivery_type_invalid, 421) if model.schedule?
    end

    def valid_delivery_time(model)
      return unless delivery_slot.slot_start.to_time < (Time.now + model.delivery_slot_skip_time.second)

      error!(CustomErrors.instance.delivery_slot_invalid, 421)
    end

    def validate_order_promo
      params[:order_id].present? && order.present? && promo_realization.order_id == params[:order_id]
    end

    def validate_promotion_code
      error!(CustomErrors.instance.invalid_promo, 421) if invalid_promotion_code
      return if promo_exist.zero?

      if validate_order_promo
        error!(CustomErrors.instance.promo_expired, 421) unless promotion_code.order_expired_now?(order.created_at)
      else
        error!(CustomErrors.instance.promo_expired, 421) unless promotion_code.expired_now?
      end
      error!(CustomErrors.instance.max_allowed_realization_exceed, 421) unless promotion_code.proper_number_of_realizations?
      error!(CustomErrors.instance.promo_not_for_retailer, 421) unless promotion_code.for_retailer?(retailer.id)
      error!(CustomErrors.instance.promo_already_used, 421) if promotion_code.used_by_shopper?(current_shopper.id, retailer.id)
      error!(CustomErrors.instance.payment_invalid_for_promo, 421) if !(promotion_code.available_payment_types.ids.include?(params[:payment_type_id])) || !accepted_promocode
      error!(CustomErrors.instance.promo_order_limit(promotion_code.order_limit), 421) unless promotion_code.order_limit_not_exceed(current_shopper.id)
      error!(CustomErrors.instance.promo_not_for_shopper, 421) unless promotion_code.for_shopper?(current_shopper.id)
      unless promotion_code.for_service?(params[:retailer_service_id])
        params[:retailer_service_id] == 1 ? error!(CustomErrors.instance.promo_only_for_delivery, 421) : error!(CustomErrors.instance.promo_only_for_cnc, 421)
      end
      promo_invalid_brands
    end

    def retailer
      @retailer ||= Retailer.find_by(id: params[:retailer_id], is_active: true)
    end

    def retailer_has_service
      @retailer_has_service ||=
        RetailerHasService.find_by(retailer_id: retailer.id, retailer_service_id: params[:retailer_service_id], is_active: true)
    end

    def payment_type
      AvailablePaymentType.joins(:retailer_has_available_payment_types).where(
        retailer_has_available_payment_types: { retailer_id: retailer.id, retailer_service_id: params[:retailer_service_id],
                                                available_payment_type_id: params[:payment_type_id] }).distinct.exists?
    end

    def shopper_address
      @shopper_address ||= ShopperAddress.find_by(shopper_id: current_shopper.id, id: params[:shopper_address_id])
    end

    def retailer_delivery_zone
      @retailer_delivery_zone ||= retailer.retailer_delivery_zone_with(shopper_address)
    end

    def retailer_opened
      params[:usid].present? || retailer.is_opened? && RetailerOpeningHour.not_schedule_close?(retailer_delivery_zone&.id)
    end

    def delivery_value_not_enough
      retailer_delivery_zone.delivery_fee.to_f.zero? && value_of_products < retailer_delivery_zone.min_basket_value.to_f
    end

    def cc_value_not_enough
      value_of_products < retailer_has_service.min_basket_value.to_f
    end

    def products_mapping
      @products_mapping ||= {}
      return @products_mapping unless @products_mapping.blank?

      params[:products].each { |p| @products_mapping[p[:product_id]] = p[:amount] }
      @products_mapping
    end

    def get_product_ids
      @get_product_ids ||= products_mapping.keys
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
        @value_of_products += get_product_price(shop) unless (cat.include? pg_18) || (sub_cat.include? pg_18)
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
      products_mapping[product_id]
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
      products_mapping.values.sum
    end

    def invalid_promotion_code
      params[:promotion_code_realization_id] && promo_exist.zero?
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
      if params[:retailer_service_id] == 1
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
      promo_threshold = SystemConfiguration.find_by(key: 'promo_threshold')
      return unless get_promo_value < (promotion_code.min_basket_value.to_f - promo_threshold&.value.to_i)

      brand_names = promotion_code.brands.limit(5).pluck('name') * ', '
      error!(CustomErrors.instance.promo_invalid_brands(brand_names, promotion_code.min_basket_value.to_f), 421)
    end

    def slot_exits
      @slot_exits ||=
        DeliverySlot.active.with_service(params[:retailer_service_id]).where(id: params[:usid].to_s[6..]).exists? ? 1 : 0
    end

    def delivery_slot
      return @delivery_slot if @delivery_slot

      @delivery_slot =
        if params[:usid] && params[:retailer_service_id] == 1
          RetailerAvailableSlot.with_service(params[:retailer_service_id]).with_zone(retailer_delivery_zone.id)
                               .find_by(usid: params[:usid], retailer_id: retailer.id)
        elsif params[:usid] && params[:retailer_service_id] == 2
          RetailerAvailableSlot.with_service(params[:retailer_service_id]).find_by(usid: params[:usid], retailer_id: retailer.id)
        end
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

    def get_products
      return @all_products if @all_products

      @all_products = if params[:order_id]
                        previous_product_ids = previous_products.keys
                        Product.products_with_shops(get_product_ids - previous_product_ids, retailer.id, delivery_time, get_product_ids & previous_product_ids)
                      else
                        Product.products_with_shops(get_product_ids, retailer.id, delivery_time)
                      end
      ActiveRecord::Associations::Preloader.new.preload(@all_products, %i[brand categories subcategories])
      ActiveRecord::Associations::Preloader.new.preload(
        @all_products, :shop_promotions,
        { where: "shop_promotions.retailer_id = #{retailer.id} AND #{delivery_time} BETWEEN shop_promotions.start_time AND shop_promotions.end_time",
          order: %i[end_time start_time] })
      @all_products
    end

    def previous_products
      @previous_products = {}
      return @previous_products if params[:order_id].blank? || @previous_products.present?

      previous_products = OrderPosition.where(order_id: params[:order_id]).select(:product_id, :amount)
      previous_products.each { |pp| @previous_products[pp.product_id] = pp.amount }
      @previous_products
    end

    def accepted_promocode
      RetailerHasAvailablePaymentType.where(retailer_id: retailer.id, available_payment_type_id: params[:payment_type_id],
                                            accept_promocode: true, retailer_service_id: params[:retailer_service_id]).exists?
    end

    def delivery_time
      @delivery_time ||= ((delivery_slot.present? && delivery_slot.slot_start || Time.now).to_time.utc.to_f * 1000).floor
    end

    def order_substitution_preference(order_id)
      order_data = OrdersDatum.find_or_initialize_by(order_id: order_id)
      subs_pref = JSON(SystemConfiguration.find_by(key: 'substitution_preference').value)
      pfk = params[:substitution_preference_key]
      subs_pref.select { |k, v| pfk = k if v['en'] == 'Send substitutions in app' } if params[:substitution_preference_key].blank?
      order_data.detail[:substitution_preference_key] = pfk.to_i
      order_data.detail[:substitution_preference_value] = subs_pref[order_data.detail[:substitution_preference_key].to_s]['en']
      order_data.detail[:is_smiles_user] = current_shopper.is_smiles_user
      order_data.save!
    end
  end
end
