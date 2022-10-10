class OrderPosition < ActiveRecord::Base
  belongs_to :order, optional: true, touch: true
  belongs_to :product, -> { unscope(:where) }, optional: true
  belongs_to :shop, optional: true
  has_many :order_substitutions, foreign_key: 'product_id', primary_key: 'product_id'
  belongs_to :product_proposal, optional: true
  # has_many :order_substitutions, through: :order

  after_commit on: [:update] do
    unavialable_product_in_shop unless was_in_shop?
  end

  def product_name
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.product.send("name_#{I18n.locale.to_s}") rescue nil
    end
    value || read_attribute(:product_name)
  end

  def product_brand_name
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.product.brand.send("name_#{I18n.locale.to_s}") rescue nil
    end
    value || read_attribute(:product_brand_name)
  end

  def product_description
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.product.send("description_#{I18n.locale.to_s}") rescue nil
    end
    value || read_attribute(:product_description)
  end

  def product_size_unit
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.product.send("size_unit_#{I18n.locale.to_s}") rescue nil
    end
    value || read_attribute(:product_size_unit)
  end

  def product_category_name
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.product.categories.first.send("name_#{I18n.locale.to_s}") rescue nil
    end
    value || read_attribute(:product_category_name)
  end

  def product_subcategory_name
    if I18n.locale != :en and I18n.available_locales.include? I18n.locale
      value = self.product.subcategories.first.send("name_#{I18n.locale.to_s}") rescue nil
    end
    value || read_attribute(:product_subcategory_name)
  end

  def product_image_url
    self.product.photo.url(:icon)
  end

  def unit_price
    self.promotional_price.positive? ? self.promotional_price : (self.shop_price_dollars + (self.shop_price_cents).to_f / 100).round(2)
  end

  def full_price
    (unit_price * amount).round(2)
  end

  def full_standard_price
    ((self.shop_price_dollars + (self.shop_price_cents).to_f / 100).round(2) * amount).round(2)
  end

  def full_income
    (self.full_price * self.commission_value / 100).round(2)
  end

  def full_promo_price
    (promotional_price * amount).round(2)
  end

  # def order_substitutions
  #   product.order_substitutions.where(order_id: self.order_id)
  # end

  def unavialable_product_in_shop
    return unless shop.present?

    # shop.owner_for_log = self.order
    if shop.is_promotional?
      if shop.detail['counter_start_time'] && (shop.detail['counter_start_time'].to_time + 7.days) <= Time.now.utc
        shop.detail['oos_weight'] = shop.detail['oos_weight'].to_i + 1
      elsif shop.detail['last_inactive_time'] && (shop.detail['last_inactive_time'].to_time + 7.days) <= Time.now.utc
        shop.detail['counter_start_time'] = shop.detail['last_inactive_time']
        shop.detail['oos_weight'] = 2
      else
        shop.detail['counter_start_time'] = Time.now.utc.to_s
        shop.detail['oos_weight'] = 1
      end
      if shop.detail['oos_weight'].to_i >= 3
        shop.is_published = false
        shop.detail['permanently_disabled'] = '1'
      end
    end
    shop.is_available = false
    shop.detail.merge!({ 'owner_type' => 'Order', 'owner_id' => order_id, 'last_inactive_time' => Time.now.utc.to_s })
    shop.save rescue ''
    # shop.update_attribute(:is_available, false) rescue ''
  end

  def update_position(substituting_product_id, amount, retailer_id, shop_promotion_id, date_time_offset)
    pr = Product.unscoped.find_by(id: substituting_product_id)
    db_shop = Shop.joins('JOIN products ON shops.product_id = products.id').where(product_id: substituting_product_id, retailer_id: retailer_id).first
    promo_shop = ShopPromotion.find_by(id: shop_promotion_id) if shop_promotion_id
    return false unless db_shop.present?

    with_stock = Retailer.stock_level(retailer_id).exists?
    return { product_id: pr.id, available_quantity: db_shop.available_for_sale.to_i } if with_stock && db_shop.available_for_sale.to_i < amount

    shop_is_promotional = false
    promotional_price = 0
    shop_id = db_shop.id
    shop_price_cents = db_shop.price_cents
    shop_price_dollars = db_shop.price_dollars
    shop_price_currency = db_shop.price_currency
    if shop_promotion_id && promo_shop
      promotional_price = promo_shop.price
      shop_is_promotional = true
    end

    product_brand_name = pr.brand&.name || 'Other'
    product_category_name = pr.categories.first&.name || 'Other'
    product_subcategory_name = pr.subcategories.first&.name || 'Other'
    self.product_id = pr.id
    self.shop_id = shop_id
    self.amount = amount
    self.product_barcode = pr.barcode
    self.brand_id = pr.brand_id
    self.product_brand_name = product_brand_name
    self.product_name = pr.name
    self.product_description = pr.description
    self.product_shelf_life = pr.shelf_life
    self.product_size_unit = pr.size_unit
    self.product_country_alpha2 = pr.country_alpha2
    self.product_location_id = pr.location_id
    self.category_id = pr.categories[0].try(:id)
    self.product_category_name = product_category_name
    self.subcategory_id = pr.subcategories[0].try(:id)
    self.product_subcategory_name = product_subcategory_name
    self.shop_price_cents = shop_price_cents
    self.shop_price_dollars = shop_price_dollars
    self.shop_price_currency = shop_price_currency
    self.was_in_shop = true
    self.is_promotional = shop_is_promotional
    self.promotional_price = promotional_price
    self.date_time_offset = date_time_offset
    [db_shop, with_stock]
  end

  def replace_position(substituting_product_id, amount, retailer_id, shop_promotion_id, date_time_offset)
    pr = Product.unscoped.find_by(id: substituting_product_id)
    db_shop = Shop.joins('JOIN products ON shops.product_id = products.id').where(product_id: substituting_product_id, retailer_id: retailer_id).first
    promo_shop = ShopPromotion.find_by(id: shop_promotion_id) if shop_promotion_id
    return false unless db_shop.present?

    with_stock = Retailer.stock_level(retailer_id).exists?
    return { product_id: pr.id, available_quantity: db_shop.available_for_sale.to_i } if with_stock && db_shop.available_for_sale.to_i < amount

    shop_is_promotional = false
    promotional_price = 0
    shop_id = db_shop.id
    shop_price_cents = db_shop.price_cents
    shop_price_dollars = db_shop.price_dollars
    shop_price_currency = db_shop.price_currency
    if shop_promotion_id && promo_shop
      promotional_price = promo_shop.price
      shop_is_promotional = true
    end

    product_brand_name = pr.brand&.name || 'Other'
    product_category_name = pr.categories.first&.name || 'Other'
    product_subcategory_name = pr.subcategories.first&.name || 'Other'

    update_order_position = {
      product_id: pr.id,
      shop_id: shop_id,
      amount: amount,
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
      was_in_shop: true,
      is_promotional: shop_is_promotional,
      promotional_price: promotional_price,
      date_time_offset: date_time_offset
      # commission_value: shop_commission_value
    }
    OrderPosition.transaction do
      if with_stock
        db_shop.available_for_sale = db_shop.available_for_sale - amount
        db_shop.is_available = false if db_shop.available_for_sale.zero?
        db_shop.save
      end
      update(update_order_position)
    end
    true
  end

  def update_proposal_position(proposal, amount, date_time_offset)
    # pr = ProductProposal.find_by(id: product_proposal_id)
    # db_shop = Shop.joins('JOIN products ON shops.product_id = products.id').where(product_id: substituting_product_id, retailer_id: retailer_id).first
    # promo_shop = ShopPromotion.find_by(id: shop_promotion_id) if shop_promotion_id
    # return false unless db_shop.present?
    db_shop = nil
    with_stock = 1
    # return { product_id: pr.id, available_quantity: db_shop.available_for_sale.to_i } if with_stock && db_shop.available_for_sale.to_i < amount

    shop_is_promotional = proposal.is_promotion_available
    promotional_price = proposal.promotional_price.to_i
    # shop_id = db_shop.id
    # shop_price_cents = db_shop.price_cents
    # shop_price_dollars = db_shop.price_dollars
    # shop_price_currency = db_shop.price_currency
    # if shop_promotion_id && promo_shop
    #   promotional_price = promo_shop.price
    #   shop_is_promotional = true
    # end

    product_brand_name =  Brand.find_by_id(proposal.brand_id)&.name || 'Other'
    product_category_name = proposal.categories.first&.name || 'Other'
    product_subcategory_name = proposal.subcategories.first&.name || 'Other'
    self.product_proposal_id = proposal.id
    self.product_id = nil
    self.amount = amount
    self.product_barcode = proposal.barcode
    self.brand_id = proposal.brand_id
    self.product_brand_name = product_brand_name
    self.product_name = proposal.name
    self.product_description = proposal.description
    self.product_size_unit = proposal.size_unit
    self.category_id = proposal.categories[0].try(:id)
    self.product_category_name = product_category_name
    self.subcategory_id = proposal.subcategories[0].try(:id)
    self.product_subcategory_name = product_subcategory_name
    self.shop_price_cents = proposal.price.to_s.split('.')[1].to_i
    self.shop_price_dollars = proposal.price.to_s.split('.')[0].to_i
    self.shop_price_currency = proposal.price_currency
    self.was_in_shop = true
    self.is_promotional = shop_is_promotional
    self.promotional_price = promotional_price
    self.date_time_offset = date_time_offset
    [db_shop, with_stock]
  end


  def replace_proposal_position(proposal, amount, date_time_offset)
    # pr = ProductProposal.find_by(id: product_proposal_id)
    # db_shop = Shop.joins('JOIN products ON shops.product_id = products.id').where(product_id: substituting_product_id, retailer_id: retailer_id).first
    # promo_shop = ShopPromotion.find_by(id: shop_promotion_id) if shop_promotion_id
    # return false unless db_shop.present?

    # with_stock = 1
    # return { product_id: pr.id, available_quantity: db_shop.available_for_sale.to_i } if with_stock && db_shop.available_for_sale.to_i < amount

    shop_is_promotional = proposal.is_promotion_available
    promotional_price = proposal.promotional_price.to_i
    # shop_id = db_shop.id
    # shop_price_cents = db_shop.price_cents
    # shop_price_dollars = db_shop.price_dollars
    # shop_price_currency = db_shop.price_currency
    # if shop_promotion_id && promo_shop
    #   promotional_price = promo_shop.pricef
    #   shop_is_promotional = true
    # end

    product_brand_name = Brand.find_by_id(proposal.brand_id)&.name || 'Other'
    product_category_name = proposal.categories.first&.name || 'Other'
    product_subcategory_name = proposal.subcategories.first&.name || 'Other'

    update_order_position = {
      product_id: nil,
      product_proposal_id: proposal.id,
      amount: amount,
      product_barcode: proposal.barcode,
      brand_id: proposal.brand_id,
      product_brand_name: product_brand_name,
      product_name: proposal.name,
      product_description: proposal.description,
      product_size_unit: proposal.size_unit,
      category_id: proposal.categories[0].try(:id),
      product_category_name: product_category_name,
      subcategory_id: proposal.subcategories[0].try(:id),
      product_subcategory_name: product_subcategory_name,
      shop_price_cents: proposal.price.to_s.split('.')[1].to_i,
      shop_price_dollars: proposal.price.to_s.split('.')[0].to_i,
      shop_price_currency: proposal.price_currency,
      was_in_shop: true,
      is_promotional: shop_is_promotional,
      promotional_price: promotional_price,
      date_time_offset: date_time_offset
      # commission_value: shop_commission_value
    }
    OrderPosition.transaction do
      # if with_stock
        # db_shop.available_for_sale = db_shop.available_for_sale - amount
        # db_shop.is_available = false if db_shop.available_for_sale.zero?
        # db_shop.save
      # end
      update(update_order_position)
    end
    true
  end

end
