require 'resque/errors'
require 'open-uri'
require 'csv'

class DigestShopCsvJob
  @queue = :csv_import_queue

  def self.perform(csv_import_id, normalize_13_digit)
    # This should iterate through csv file rows
    # and for each row it should find a corresponding product
    # then add it to retailer's shop.
    # rowNumber = 0
    # successfulInserts = 0
    # failedInserts = 0
    # barcodeIndex = 1
    # priceIndex = 1

    csv_record = CsvImport.find(csv_import_id)
    @detail = { 'owner_type' => csv_record.class.name, 'owner_id' => csv_record.id }
    csv = if Rails.env.production? || Rails.env.staging?
            open(csv_record.csv_import.url, 'r:utf-8').read
          else
            File.open(csv_record.csv_import.path, mode: 'r:bom|utf-8')
          end

    @csv_failed_path = "#{Rails.root.to_s}/tmp/#{csv_record.id}_failed_rows.csv"
    @csv_success_path = "#{Rails.root.to_s}/tmp/#{csv_record.id}_successful_rows.csv"

    csv_failed_rows = []
    csv_successful_rows = []

    ex_retailer_products = Hash.new([])
    # successful_ids = []

    csv_failed_headers = %w[barcode price retailer_id is_promotional is_published price_currency standard_price percentage_off start_time end_time product_limit promotion_only enable_product]
    csv_success_headers = %w[barcode price retailer_id product_name retailer_name is_promotional is_published]

    case File.extname(csv_record.csv_import_file_name)
    when '.csv'
      csv_obj = CSV.parse(csv, headers: true, header_converters: ->(f) { f.delete(' ').downcase })
      csv_obj.each do |row|
        retailer_id = row['retailer_id'].to_i
        barcode = row['barcode']
        next if barcode.blank? # skip empty lines

        barcode = normalize_13_digit.to_i.positive? ? barcode.sub(barcode.split('-')[0], barcode.split('-')[0].rjust(13, '0')) : barcode
        product = Product.select(:id, :name, :is_promotional).where("products.name IS NOT NULL and barcode = '#{barcode}'").first
        unless product
          csv_failed_rows.push([barcode, row['price'], row['retailer_id'], row['is_promotional'], row['is_published'], row['price_currency'], row['standard_price'], row['percentage_off'], row['start_time'], row['end_time'], row['product_limit'], row['promotion_only'], row['enable_product']])
          next
        end
        price = row['price'].to_f
        row['standard_price'] = row['standard_price'].to_f
        row['percentage_off'] = row['percentage_off'].to_f
        shop_price = price
        is_promotional = row['is_promotional'].to_s.downcase.strip.eql?('true')
        is_published = row['is_published'].blank? ? true : row['is_published'].to_s.downcase.strip.eql?('true')
        enabling_product = row['enable_product'].blank? ? false : row['enable_product'].to_s.downcase.strip.eql?('true')
        promotion_only = row['promotion_only'].to_s.downcase.strip.eql?('true')
        promo_updated = false
        if is_promotional
          if row['start_time'].blank? || row['end_time'].blank? || row['start_time'].to_time >= row['end_time'].to_time || (row['standard_price'] > 0.0 && row['standard_price'] < price)
            csv_failed_rows.push([barcode, row['price'], row['retailer_id'], row['is_promotional'], row['is_published'], row['price_currency'], row['standard_price'], row['percentage_off'], row['start_time'], row['end_time'], row['product_limit']])
            next
          end
          if row['standard_price'] > 0.0
            standard_price = row['standard_price']
            shop_price = standard_price
          elsif row['percentage_off'] > 0.0
            standard_price = ((price * 100.0) / (100.0 - row['percentage_off'])).round(2)
            shop_price = standard_price
          else
            price_data = Shop.select("MAX(price_dollars + price_cents/100.0) AS max_price, SUM(price_dollars + shops.price_cents/100.0) FILTER ( WHERE retailer_id = #{retailer_id} ) AS shop_price").where(product_id: product.id).limit(1)[0]
            standard_price = if price_data&.shop_price.to_f.round(2) > price
                               shop_price = price_data&.shop_price.to_f.round(2)
                               shop_price
                             else
                               promotion_only = true
                               price_data&.max_price.to_f.round(2)
                             end
            standard_price = standard_price > price ? standard_price : price
          end
          promo_updated = product.add_shop_promotion(retailer_id, standard_price, price, row['start_time'], row['end_time'], row['product_limit'].to_i, row['price_currency'])
        end
        price_dollars = shop_price.to_i
        price_cents = ((shop_price - price_dollars) * 100).round
        promo_updated = product.add_to_shop_raw(retailer_id, price_cents, price_dollars, is_promotional: is_promotional, is_published: is_published, detail: @detail, promotion_only: promotion_only, promo_updated: promo_updated, price_currency: (row['price_currency'] || 'AED'), enabling_disabled: enabling_product)
        # successful_ids << product.id if promo_updated
        csv_successful_rows.push([barcode, row['price'], row['retailer_id'], product.name, row['retailer_id'], row['is_promotional'], row['is_published']])
        ex_retailer_products[retailer_id] = ex_retailer_products[retailer_id] << product.id
      end
    when '.xlsx'
      csv_obj = Roo::Spreadsheet.open(csv)
      csv_obj.each(barcode: 'barcode', price: 'price', description: 'retailer_id') do |row|
        barcode = row[:barcode].to_s.split('.')[0]
        barcode = normalize_13_digit.to_i.positive? ? barcode.sub(barcode.split('-')[0], barcode.split('-')[0].rjust(13, '0')) : barcode
        product = Product.select(:id, :name).where("products.name IS NOT NULL and products.brand_id IS NOT NULL and barcode = '#{barcode}'").first
        if product
          retailer_id = row[:retailer_id].to_i
          price_dollars = row[:price].to_i
          price_cents = ((row['price'].to_f - price_dollars) * 100).round
          is_promotional = row[:is_promotional].blank? ? nil : row[:is_promotional].downcase.try(:strip).eql?('true')
          is_published = row[:is_published].blank? ? true : row[:is_published].downcase.try(:strip).eql?('true')
          product.add_to_shop_raw(retailer_id, price_cents, price_dollars, is_promotional: is_promotional, is_published: is_published, detail: @detail)
          # successful_ids.push(product.id)
          csv_successful_rows.push([barcode, row[:price], retailer_id, product.name, row[:retailer_id], row[:is_promotional], row[:is_published]])
        else
          csv_failed_rows.push([barcode, row[:price], row[:retailer_id], row[:is_promotional], row[:is_published]])
        end
      end
    end

    # self.index_update(product_ids: successful_ids.uniq)

    if csv_record.is_unpublish_other
      ex_retailer_products.keys.each do |rid|
        # shops = Shop.joins(:categories).where('shops.retailer_id = ? and shops.is_published = true', rid[:retailer_id]).where.not(product_id: ex_retailer_products.select{|d|  d[:retailer_id] == rid[:retailer_id]}.map{|v| v[:product_id]}).where.not(categories: { id: csv_record.unpublish_exclude_categories.split(',') })
        shops = Shop.unscoped.where(retailer_id: rid, is_published: true).where.not(product_id: ex_retailer_products[rid])
        if csv_record.unpublish_exclude_categories.present?
          shops = shops.joins('JOIN product_categories ON product_categories.product_id = shops.product_id')
          shops = shops.joins("JOIN categories ON categories.id = product_categories.category_id AND categories.parent_id IS NOT NULL AND categories.parent_id NOT IN (#{csv_record.unpublish_exclude_categories})")
        end
        shop_prod_ids = shops.pluck(:product_id)
        shops.update_all(is_published: false, updated_at: DateTime.now, detail: @detail)
        self.index_update(shops: shop_prod_ids) rescue ''
        # shops.each do |shop|
        # shop.is_published = false
        # begin
        # Resque.enqueue(Indexer, :delete, shop.class.name, shop.id)
        # Shop.__elasticsearch__.client.bulk({
        #   index: ::Shop.__elasticsearch__.index_name,
        #   type: ::Shop.__elasticsearch__.document_type,
        #   body: shops.map do |shop|
        #     { update: { _id: shop.id, data: {doc: { is_published: false }} } }
        #   end
        # })
        # rescue Exception => e
        # end
        # end
      end
    end

    csv_record.successful_inserts = csv_successful_rows.count
    csv_record.failed_inserts = csv_failed_rows.count

    self.insert_data_to_csv(@csv_success_path, csv_success_headers, csv_successful_rows)
    self.insert_data_to_csv(@csv_failed_path, csv_failed_headers, csv_failed_rows)

    csv_failed_data = File.open(@csv_failed_path)
    csv_success_data = File.open(@csv_success_path)

    csv_record.csv_failed_data = csv_failed_data
    csv_record.csv_failed_data.instance_write(:content_type, 'text/csv')
    csv_record.csv_successful_data = csv_success_data
    csv_record.csv_successful_data.instance_write(:content_type, 'text/csv')
    csv_record.save!

    csv_failed_data.close
    csv_success_data.close
  end

  private

  def self.index_update(shops: nil, product_ids: nil)
    # bulk update on ES
    #Shop.__elasticsearch__.client.bulk({
    #  index: ::Shop.__elasticsearch__.index_name,
    #  type: ::Shop.__elasticsearch__.document_type,
    #  body: shop_ids.map do |shop|
    #    { update: { _id: shop, data: {doc: { is_published: false }} } }
    #  end
    #}) rescue ''

    # bulk update algolia
    prod_ids = product_ids || shops
    unless prod_ids.blank?
      prod_ids.each_slice(1000) do |pro_ids|
        AlgoliaProductIndexingJob.perform_later(pro_ids)
      end
    end
  end

  def self.insert_data_to_csv(path, headers, data)
    CSV.open(path, 'wb') do |csv|
      csv << headers
      data.each do |row|
        csv << row
      end
    end
  end

end
