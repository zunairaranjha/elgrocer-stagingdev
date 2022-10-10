require 'resque/errors'
require 'open-uri'
require 'csv'

class DigestShopPromotionJob
  @queue = :csv_import_queue

  def self.perform(csv_id)

    csv_record = CsvImport.find_by(id: csv_id)
    if Rails.env.production? || Rails.env.staging?
      csv = open(csv_record.csv_import.url, "r:utf-8").read
    else
      csv = File.open(csv_record.csv_import.path, mode: 'r:bom|utf-8')
    end

    @failed_csv_path = "#{Rails.root.to_s}/tmp/failed_rows.csv"

    failed_csv_rows = []
    successful_count = 0
    product_ids = []
    failed_csv_headers = %w[barcode standard_price price price_currency product_limit retailer_id start_time end_time]

    if File.extname(csv_record.csv_import_file_name) == ".csv"
      csv_obj = CSV.parse(csv, headers: true, header_converters: -> (f) { f.delete(' ').downcase })
      time = Time.now
      csv_obj.each_slice(1000) do |rows|
        promotions = []
        rows.each do |row|
          barcode = row['barcode']
          next if barcode.blank? #skip empty lines
          product = Product.select(:id).where(barcode: barcode).where.not(name: nil).first
          if product && row['retailer_id'].present? && row['standard_price'].present? && row['price'].present? && row['price_currency'].present? && row['start_time'].present? && row['end_time'].present? && row['product_limit'].present?
            promotions << ShopPromotion.new(product_id: product.id, standard_price: row['standard_price'].to_f, price: row['price'].to_f, price_currency: row['price_currency'], product_limit: row['product_limit'].to_i, retailer_id: row['retailer_id'].to_i,
                                            start_time: (row['start_time'].to_time.utc.to_f * 1000).floor, end_time: (row['end_time'].to_time.utc.to_f * 1000).floor, created_at: time, updated_at: time)
            product_ids << product.id
            successful_count += 1
          else
            failed_csv_rows.push([barcode, row['standard_price'], row['price'], row['price_currency'], row['product_limit'], row['retailer_id'], row['start_time'], row['end_time']])
          end
        end
        ShopPromotion.transaction do
          ShopPromotion.import promotions
        end
      end
      index_update(product_ids: product_ids) rescue ''
    end

    csv_record.successful_inserts = successful_count
    csv_record.failed_inserts = failed_csv_rows.count

    self.insert_data_to_csv(@failed_csv_path, failed_csv_headers, failed_csv_rows)

    failed_csv_data = File.open(@failed_csv_path)

    csv_record.csv_failed_data = failed_csv_data
    csv_record.csv_failed_data.instance_write(:content_type, 'text/csv')
    csv_record.save!

    failed_csv_data.close
  end

  private

  def index_update(shops: nil, product_ids: nil)
    # bulk update algolia
    prod_ids = product_ids || shops
    unless prod_ids.blank?
      prod_ids.each_slice(1000) do |pro_ids|
        AlgoliaProductIndexingJob.perform_later(pro_ids)
      end
    end
  end

  def self.insert_data_to_csv(path, headers, data)
    CSV.open(path, "wb") do |csv|
      csv << headers
      data.each do |row|
        csv << row
      end
    end
  end

end

