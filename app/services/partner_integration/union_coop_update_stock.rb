class PartnerIntegration::UnionCoopUpdateStock

  def initialize
    @fvn_subcategory_ids = [142, 174, 778, 839]
    @meat_subcategory_ids = [119, 161, 217, 291, 385, 386, 387, 592, 593, 594, 595, 725, 726, 727, 728, 729, 730, 731, 732, 733, 734, 774, 775]
    @seafood_subcategory_ids = [388]
    @barcodes_na = []
    @barcodes_dup = []
    @proxy = URI(ENV['PROXY_URL'])
    @client = HTTPClient.new(@proxy)
    @client.set_proxy_auth(@proxy.user, @proxy.password)
    @client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @uc_promotion_days = Integer(Redis.current.get('uc_promotion_days') || SystemConfiguration.find_by_key('uc_promotion_days')&.value || 7)
  end

  def get_data(partners)
    partners.each do |partner|
      headers = { 'username': partner.user_name, 'password': partner.password, 'Content-Type': "multipart/form-data" }
      retailer = Retailer.find_by(id: partner.retailer_id)
      analytic = Analytic.order(id: 'desc').find_by(owner: retailer, event_id: Event.find_or_create_by(name: 'UC Update Stock'))
      last_updated = analytic ? analytic.created_at.to_time : Time.now - 30.minutes
      page_number = 1
      loop do
        body = { 'branch_code' => partner.branch_code,
                 'last_updated_date' => last_updated,
                 'page' => page_number,
                 'limit' => '3000'
        }
        response = @client.post partner.api_url + '/onlinepartners/api/getAllProductInventory', body, headers
        response = JSON(response.body)
        if (response['status'] == 'success' && !response['inventory_data'].any?) || response['status'] == 'error'
          break
        end
        page_number += 1
        update_data(response['inventory_data'], retailer, partner)
      end
      RetailerMailer.missing_barcodes(@barcodes_na, @barcodes_dup, retailer.id).deliver_later if @barcodes_na.any? || @barcodes_dup.any?
      Analytic.add_activity("UC Update Stock", retailer, "Cloned Barcodes: #{@barcodes_dup} \r\n Missing Barcodes: #{@barcodes_na}") if page_number > 1
      @barcodes_na = []
      @barcodes_dup = []
    end
  end

  def update_data(products, retailer, partner)
    products.each do |product|
      shop_product = Product.where("products.name IS NOT NULL and products.brand_id IS NOT NULL and barcode = '#{product['barcode']}'").first
      if shop_product
        puts('in tagging')
        update_shop(product, shop_product, retailer, partner)
      elsif (prod = Product.unscoped.find_by(barcode: product['barcode'].to_s.sub(/^0*/, '')))
        puts('in cloning')
        shop_product = Product.new(prod.attributes.merge(id: nil, barcode: product['barcode'], created_at: Time.now, updated_at: Time.now))
        shop_product.subcategories = prod.subcategories
        shop_product.photo = prod.photo
        shop_product.save rescue ''
        update_shop(product, shop_product, retailer, partner) if shop_product.persisted?
        @barcodes_dup.push(shop_product.barcode)
      else
        @barcodes_na.push(product['barcode'])
      end
    end
  end

  def update_shop(product, shop_product, retailer, partner)
    sub_cat_ids = shop_product.subcategory_ids
    lrd = product['last_received_date'].present? ? product['last_received_date'].to_time : 1.year.ago.to_time
    product['is_promotion_item'] = product['is_promotion_item'].to_s.downcase
    promotional = product['is_promotion_item'].eql?('p') || product['is_promotion_item'].eql?('t')
    time = Time.now.beginning_of_day
    price = product['price'].to_f
    available = false
    if product['barcode'].length == 5
      available = ((@fvn_subcategory_ids & sub_cat_ids).any? && lrd >= (time - 1.day) ||
        ((@meat_subcategory_ids & sub_cat_ids).any?) || ((@seafood_subcategory_ids & sub_cat_ids).any? && lrd >= time))
      update_variants(product, promotional, retailer.id, available, partner, lrd)
    else
      available = promotional ? product['qty'].to_i >= partner.promotional_min_stock : product['qty'].to_i >= partner.min_stock
    end
    set_shop(shop_product.id, retailer.id, price, available, promotional, partner, lrd)
  end

  def update_variants(product, promotional, retailer_id, available, partner, lrd)
    shop_products = Product.select(:id, :barcode).where("products.name IS NOT NULL and products.brand_id IS NOT NULL and barcode in ('#{product['barcode']}-500', '#{product['barcode']}-250', '#{product['barcode']}-100')")
    shop_products.each do |shop_product|
      price = product['price'].to_f
      if shop_product.barcode.include?('-500')
        price = (price * 0.5)
      elsif shop_product.barcode.include?('-250')
        price = (price * 0.25)
      elsif shop_product.barcode.include?('-100')
        price = (price * 0.1)
      end
      set_shop(shop_product.id, retailer_id, price, available, promotional, partner, lrd)
    end
  end

  def set_shop(product_id, retailer_id, price, available, promotional, partner, lrd)
    shop = Shop.unscoped.where(product_id: product_id, retailer_id: retailer_id).first_or_initialize
    if promotional && available && (shop_promotion = ShopPromotion.unscoped.find_by(retailer_id: retailer_id, product_id: product_id, price_currency: 'AED'))
      shop_promotion.is_active = available
      shop_promotion.end_time = ((Time.now.end_of_day + @uc_promotion_days.day).to_time.utc.to_f * 1000).floor if (shop_promotion.end_time || Time.now) < ((Time.now + 1.day).to_time.utc.to_f * 1000).floor
      shop_promotion.save rescue ''
    end
    if price > 0.0
      shop.price_dollars = price.to_i
      shop.price_cents = (price.to_f - price.to_i).round(2) * 100
    end
    shop.is_available = available
    shop.is_promotional = promotional
    detail = { 'owner_type' => partner.class.name, 'owner_id' => partner.id, 'lrd' => lrd }
    if shop.changed?
      shop.detail = shop.detail.merge(detail)
      shop.save rescue ''
    else
      shop.detail = shop.detail.merge(detail)
      shop.update_column(:detail, detail) if shop.detail_changed?
    end
  end

  def get_standard_price(shop, price)
    if (shop.price_dollars + shop.price_cents/100.0).round(2) > price
      standard_price = (shop.price_dollars + shop.price_cents/100.0).round(2)
    else
      standard_price = Shop.where(product_id: shop.product_id).maximum('shops.price_dollars + shops.price_cents/100.0').to_f.round(2)
      standard_price = standard_price > price ? standard_price : price
    end
    standard_price
  end

  # def get_barcode_price(partner, barcode)
  #   proxy = URI(ENV["PROXY_URL"])
  #   client = HTTPClient.new(proxy)
  #   client.set_proxy_auth(proxy.user, proxy.password)
  #   headers = { 'username': partner.user_name, 'password': partner.password, 'Content-Type': "multipart/form-data" }
  #   branch_code = partner.branch_code
  #   host_url = partner.api_url
  #   body = {
  #     'barcode' => barcode,
  #     'branch_code' => branch_code
  #   }
  #   response = client.post host_url + '/onlinepartners/api/getProductPrice', body, headers
  #   JSON(response.body)
  # end

end
