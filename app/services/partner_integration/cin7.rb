# frozen_string_literal: true

# This Class will fetch product Information from Cin7
require 'uri'
require 'json'
require 'net/http'

class PartnerIntegration::Cin7

  def initialize
    @barcodes_na = []
    @barcodes_dup = []
  end

  def get_data(partners)
    partners.each do |partner|
      last_sync_time = (Redis.current.get("cin7_#{partner.retailer_id}_last_sync_time")&.to_time || Time.now.yesterday).utc
      if ((Time.now.utc - last_sync_time) / 60).to_i < (SystemConfiguration.find_by(key: 'cin7_inventory_call_duration').value.to_i - 1)
        next
      end

      page_number = 1
      client = HTTPClient.new
      client.set_auth(partner.api_url, partner.user_name, partner.password)
      loop do
        body = {
          fields: 'status,modifiedDate,productOptionCode,productOptionBarcode,retailPrice,wholesalePrice,specialPrice,specialsStartDate,specialDays,stockAvailable,stockOnHand,priceColumns',
          where: "modifieddate>='#{last_sync_time.iso8601}'",
          page: page_number,
          rows: 250
        }
        response = client.get "#{partner.api_url}/v1/productoptions", body
        unless response.ok?
          Analytic.add_activity('Fetch Price Stock Failed', partner.retailer,
                                "response_code: #{response.status}, response: #{response.body}")
          break
        end
        break if response.ok? && (response_body = JSON(response.body)).blank?

        page_number += 1
        # update_data(response_body, partner)
        update_products('', response_body, partner)
      end
      Redis.current.set("cin7_#{partner.retailer_id}_last_sync_time", Time.now.iso8601)
      if @barcodes_na.any? || @barcodes_dup.any?
        RetailerMailer.missing_barcodes(@barcodes_na, @barcodes_dup, partner.retailer_id).deliver_later
      end
      Analytic.add_activity('Fetch Price Stock', partner.retailer, page_number == 1 ? 'No Data' : "Cloned Barcodes: #{@barcodes_dup.to_s} Missing Barcodes: #{@barcodes_na.to_s}")
    end
  end

  def update_data(response, partner)
    response.each do |item|
      update_products(item['status'], item['productOptions'], partner)
    end
  end

  def update_products(item_status, products, partner)
    products.each do |product|
      shop_product = Product.select(:id).where("products.name IS NOT NULL and products.brand_id IS NOT NULL and barcode = '#{product['productOptionBarcode']}'").first
      if shop_product
        update_shop(item_status, product, shop_product, partner)
      else
        @barcodes_na.push(product['productOptionBarcode'])
      end
    end
  end

  def update_shop(status, product, shop_product, partner)
    promotional = set_promotion(product, shop_product, partner) unless product['specialsStartDate'].blank?
    set_shop(shop_product.id, partner, product, !status.downcase.eql?('inactive'), promotional)
  end

  def set_shop(product_id, partner, product, available, promotional)
    price = product['retailPrice']
    shop = Shop.unscoped.where(product_id: product_id, retailer_id: partner.retailer_id).first_or_initialize
    if (shop.detail['last_inactive_time'] && shop.detail['last_inactive_time'].to_time > (Time.now - 1.day).utc) || shop.detail['permanently_disabled'].to_i.positive?
      return false
    end

    shop.price_dollars = price.to_i
    shop.price_cents = (price.to_f - price.to_i).round(2) * 100
    shop.is_available = available && !product['status'].downcase.eql?('disabled') && product['stockAvailable'].positive? # > partner.min_stock
    shop.stock_on_hand = product['stockOnHand']
    shop.available_for_sale = product['stockAvailable']
    shop.is_promotional = promotional
    detail = { 'owner_type' => partner.class.name, 'owner_id' => partner.id }
    if shop.changed?
      shop.detail = shop.detail.merge(detail)
      begin
        shop.save
      rescue
        nil
      end
    else
      shop.detail = shop.detail.merge(detail)
      shop.update_column(:detail, detail) if shop.detail_changed?
    end
  end

  def set_promotion(product, shop_product, partner)
    start_time = product['specialsStartDate'].to_time
    end_time = start_time + product['specialDays'].to_i.day
    shop_promotion = ShopPromotion.find_or_initialize_by(retailer_id: partner.retailer_id, product_id: shop_product.id,
                                                         price_currency: 'AED')
    shop_promotion.standard_price = product['retailPrice']
    shop_promotion.price = product['specialPrice']
    shop_promotion.start_time = (start_time.to_f * 1000).floor
    shop_promotion.end_time = (end_time.to_f * 1000).floor
    shop_promotion.is_active = Time.now.utc.between?(start_time, end_time)
    if shop_promotion.persisted? || Time.now.utc.between?(start_time, end_time)
      begin
        shop_promotion.save
        true
      rescue
        false
      end
    else
      false
    end
  end

  def post_order(partner, order)
    body = order_params(order, partner)
    url = URI("#{partner.api_url}/v1/salesorders")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request['Authorization'] = "Basic #{Base64.encode64("#{partner.user_name}:#{partner.password}").gsub("\n", '')}"
    request['Content-Type'] = 'application/json'
    request.body = body.to_json
    response = https.request(request)
    validate_response(response, order, 'Post Order')
    response
  end

  def modify_order(partner, order)
    cin7_order_id = OrdersDatum.find_by(order_id: order.id)&.detail.to_h['cin7_order_id']
    unless cin7_order_id
      Analytic.add_activity('Modify Order Cin7: Failed', order, 'Unable to find Cin7 Id in DB')
      return false
    end

    body = order_params(order, partner)
    body.first[:id] = cin7_order_id
    url = URI("#{partner.api_url}/v1/salesorders")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Put.new(url)
    request['Authorization'] = "Basic #{Base64.encode64("#{partner.user_name}:#{partner.password}").gsub("\n", '')}"
    request['Content-Type'] = 'application/json'
    request.body = body.to_json
    response = https.request(request)
    validate_response(response, order, 'Modify Order')
    response
  end

  def update_stage(partner, order)
    cin7_order_id = OrdersDatum.find_by(order_id: order.id)&.detail.to_h['cin7_order_id']
    unless cin7_order_id
      Analytic.add_activity('Update Order Stage Cin7: Failed', order, 'Unable to find Cin7 Id in DB')
      return false
    end
    body = { id: cin7_order_id, stage: order.status.humanize, modifiedDate: order.updated_at.utc.iso8601 }
    body[:dispatchedDate] = order.processed_at.utc.iso8601 if order.status_id == 2
    body[:isVoid] = true if order.status_id == 4
    body = [body]
    if order.status_id == 11
      body = order_params(order, partner)
      body.first[:stage] = order.status.humanize
      body.first[:id] = cin7_order_id
      body.first[:invoiceDate] = order.updated_at.utc.iso8601
      body.first[:invoiceNumber] = order.receipt_no
    end
    url = URI("#{partner.api_url}/v1/salesorders")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Put.new(url)
    request['Authorization'] = "Basic #{Base64.encode64("#{partner.user_name}:#{partner.password}").gsub("\n", '')}"
    request['Content-Type'] = 'application/json'
    request.body = body.to_json
    response = https.request(request)
    validate_response(response, order, "Update Order Stage #{order.status.humanize}")
    response
  end

  def order_params(order, partner)
    [
      {
        reference: order.id.to_s,
        createdDate: order.created_at.utc.iso8601,
        modifiedDate: order.updated_at.utc.iso8601,
        estimatedDeliveryDate: order.estimated_delivery_at.utc.iso8601,
        productTotal: order.total_value.round(2),
        discountTotal: order_discount(order),
        discountDescription: promo_code(order)&.code.to_s,
        surcharge: order.service_fee.to_f,
        surchargeDescription: 'Service Fee',
        freightTotal: (order.delivery_fee.to_f + order.rider_fee.to_f).round(2),
        freightDescription: 'Delivery Fee + Rider Fee',
        total: (order.total_value + order.delivery_fee.to_f + order.rider_fee.to_f + order.service_fee.to_f).round(2),
        currencyCode: 'AED',
        currencySymbol: 'AED',
        source: order.device_type,
        memberEmail: Retailer.select(:email).find_by(id: order.retailer_id)&.email.to_s,
        firstName: order.retailer_company_name,
        branchId: partner.branch_code,
        paymentTerms: order.payment_type,
        customerOrderNo: order.id.to_s,
        deliveryInstructions: order.shopper_note.to_s,
        status: 'Approved',
        # customFields: {
        #   date_time_offset: { time_zone: order.date_time_offset.to_s }
        # },
        lineItems: order_positions(order.id)
      }
    ]
  end

  def validate_response(response, order, task)
    if response.code.to_i == 200 && (response_body = JSON(response.body).first) && response_body['success']
      order_data = OrdersDatum.find_or_initialize_by(order_id: order.id)
      order_data.detail = order_data.detail.merge({ 'cin7_order_id' => response_body['id'] })
      order_data.save!
      Analytic.add_activity("#{task} Cin7: Success", order, response.body)
    else
      Analytic.add_activity("#{task} Cin7: Failed", order, response.body)
    end
  end

  def order_discount(order)
    if order_promo_realization(order).present?
      ((order_promo_realization(order).discount_value.to_i.positive? ? order.promotion_code_realization.discount_value : promo_code(order)&.value_cents) / 100.0).round(2)
    else
      0.0
    end
  end

  def promo_code(order)
    @promo_code ||= order_promo_realization(order)&.promotion_code
  end

  def order_promo_realization(order)
    @order_promo_realization ||= order.promotion_code_realization
  end

  def order_positions(order_id)
    order_positions = OrderPosition.select(:amount, :product_barcode).where(was_in_shop: true, order_id: order_id)
    order_positions.map { |op| { "qty": op.amount, "barcode": op.product_barcode } }
  end
end
