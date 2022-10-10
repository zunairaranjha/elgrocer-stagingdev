class PartnerIntegration::UnionCoopUpdatePrice

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
    if (partner = partners.first)
      headers = { 'username': partner.user_name, 'password': partner.password, 'Content-Type': "multipart/form-data" }
      retailer = Retailer.find_by(id: partner.retailer_id)
      retailer = Retailer.find_by(report_parent_id: retailer.report_parent_id) if retailer.report_parent_id
      analytic = Analytic.order(id: 'desc').find_by(owner: retailer, event_id: Event.find_or_create_by(name: 'UC Update Price'))
      last_updated = analytic ? analytic.created_at.to_time : Time.now - 2.hours
      page_number = 1
      loop do
        body = { 'branch_code' => partner.branch_code,
                 'last_updated_date' => last_updated,
                 'page' => page_number,
                 'limit' => '3000'
        }
        response = @client.post partner.api_url + '/onlinepartners/api/getAllProductPrice', body, headers
        response = JSON(response.body)
        if (response['status'] == 'success' && !response['price_data'].any?) || response['status'] == 'error'
          break
        end
        page_number += 1
        update_data(response['price_data'], partners)
      end
      RetailerMailer.missing_barcodes(@barcodes_na, @barcodes_dup, retailer.id).deliver_later if @barcodes_na.any? || @barcodes_dup.any?
      Analytic.add_activity("UC Update Price", retailer, "Cloned Barcodes: #{@barcodes_dup} \r\n Missing Barcodes: #{@barcodes_na}") if page_number > 1
      @barcodes_na = []
      @barcodes_dup = []
    end
  end

  def update_data(products, partners)
    products.each do |product|
      # lrd = product['last_received_date'].present? ? product['last_received_date'].to_time : 1.year.ago.to_time
      product['promotion_item'] = product['promotion_item'].to_s.downcase
      promotional = product['promotion_item'].eql?('p') || product['promotion_item'].eql?('t')
      shop_product = Product.where("products.name IS NOT NULL and products.brand_id IS NOT NULL and barcode = '#{product['barcode']}'").first
      if shop_product
        puts('in tagging')
        update_shop(product, shop_product, promotional, partners)
      elsif (prod = Product.unscoped.find_by(barcode: product['barcode'].to_s.sub(/^0*/, '')))
        puts('in cloning')
        shop_product = Product.new(prod.attributes.merge(id: nil, barcode: product['barcode'], created_at: Time.now, updated_at: Time.now))
        shop_product.subcategories = prod.subcategories
        shop_product.photo = prod.photo
        shop_product.save rescue ''
        update_shop(product, shop_product, promotional, partners) if shop_product.persisted?
        @barcodes_dup.push(shop_product.barcode)
      else
        @barcodes_na.push(product['barcode'])
      end
    end
  end

  def update_shop(product, shop_product, promotional, partners)
    partners.each do |partner|
      price = product['price'].to_f
      shop = Shop.unscoped.where(product_id: shop_product.id, retailer_id: partner.retailer_id).first_or_initialize
      unless shop.persisted?
        # stock = get_barcode_inventory(partner, product['barcode'])
        # lrd = stock['last_received_date'].present? ? stock['last_received_date'].to_time : 1.year.ago.to_time
        # promotional = stock['is_promotion_item'].present? ? stock['is_promotion_item'].downcase.eql?("p") : false
        # qty = stock['qty']
        # sub_cat_ids = shop_product.subcategory_ids
        # if product['barcode'].length == 5 and (((@fvn_subcategory_ids & sub_cat_ids).any? && lrd >= (Time.now.beginning_of_day - 1.day)) || ((@meat_subcategory_ids & sub_cat_ids).any?) || ((@seafood_subcategory_ids & sub_cat_ids).any? && lrd >= (Time.now.beginning_of_day)))
        #   shop.is_available = true
          # update_variants(product, promotional, partner.retailer_id, true )
        # elsif product['barcode'].length == 5 and (((@fvn_subcategory_ids & sub_cat_ids).any? && lrd < (Time.now.beginning_of_day - 1.day)) || ((@seafood_subcategory_ids & sub_cat_ids).any? && lrd < (Time.now.beginning_of_day)))
          shop.is_available = false
          # update_variants(product, promotional, partner.retailer_id, false )
        # else
        #   shop.is_available = promotional ? qty.to_i >= partner.promotional_min_stock : qty.to_i >= partner.min_stock
        # end
      end
      update_variants(product, promotional, partner.retailer_id, shop.is_available, partner, nil) if product['barcode'].length == 5
      shop.price_dollars = price.to_i
      shop.price_cents = (price.to_f - price.to_i).round(2) * 100
      shop.is_promotional = promotional
      shop.save rescue ''
    end
  end

  def update_variants(product, promotional, retailer_id, available, partner, lrd)
    shop_products = Product.where("products.name IS NOT NULL and products.brand_id IS NOT NULL and barcode in ('#{product['barcode']}-500', '#{product['barcode']}-250', '#{product['barcode']}-100')")
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
    if promotional
      shop_promotion = ShopPromotion.find_or_initialize_by(retailer_id: retailer_id, product_id: product_id, price_currency: 'AED')
      shop_promotion.is_active = available
      if shop_promotion.persisted?
        if shop_promotion.price != price
          shop_promotion.update_columns(end_time: ((Time.now.end_of_day + @uc_promotion_days.day).to_time.utc.to_f * 1000).floor,
                                        price: price, standard_price: get_standard_price(shop, price))
        elsif shop_promotion.end_time < ((Time.now + 1.day).to_time.utc.to_f * 1000).floor
          shop_promotion.update_columns(end_time: ((Time.now.end_of_day + @uc_promotion_days.day).to_time.utc.to_f * 1000).floor)
        end
      else
        shop_promotion.standard_price = get_standard_price(shop, price)
        shop_promotion.price = price
        shop_promotion.product_limit = 0
        shop_promotion.start_time = (Time.now.to_time.utc.to_f * 1000).floor
        shop_promotion.end_time = ((Time.now.end_of_day + @uc_promotion_days.day).utc.to_time.to_f * 1000).floor
        ShopPromotion.import [shop_promotion]
      end
    end
    shop.price_dollars = price.to_i
    shop.price_cents = (price.to_f - price.to_i).round(2) * 100
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

  # def get_barcode_inventory(partner, barcode)
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
  #   response = client.post host_url + '/onlinepartners/api/getProductInventory', body, headers
  #   JSON(response.body)
  # end

end
