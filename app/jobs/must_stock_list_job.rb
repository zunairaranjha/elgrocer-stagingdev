require 'resque/errors'
require 'open-uri'
require 'csv'

class MustStockListJob
  @queue = :csv_import_queue
  def self.perform(msl_id)
    csvRecord = MustStockList.find(msl_id)
    # retailer_id = csvRecord.retailer_id

    if Rails.env.production? || Rails.env.staging?
      csv = open(csvRecord.csv_import.url, "r:utf-8").read
    else
      csv = File.open(csvRecord.csv_import.path, mode: 'r:bom|utf-8')
    end

    @csvShopPath = "#{Rails.root.to_s}/tmp/shops.csv"
    # @csvProductPath = "#{Rails.root.to_s}/tmp/products.csv"

    csvShopPath = []
    # csvProductPath = []

    csvShopHeaders = ['barcode','retailer_id','in_shop','in_product']
    # csvProductHeaders = ['barcode','retailer_id','in_product']

    if File.extname(csvRecord.csv_import_file_name) == ".csv"
      csvObj = CSV.parse(csv, headers: true)

      csvObj.each do |row|
        # rowNumber = rowNumber + 1
        retailer_id = row['retailer_id'].to_i
        product = Product.unscoped.find_by(barcode: row['barcode'].to_s )
        product_in_shop = Shop.unscoped.joins(:product).where("shops.retailer_id=? and products.barcode=?",row['retailer_id'].to_i, row['barcode'].to_s)
        available = product_in_shop.pluck(:is_available)
        published = product_in_shop.pluck(:is_published)
        # product_exists = product.present?
        # shop_exists = product_in_shop.present?
        if product_in_shop.present?
          if (available[0] == true and published[0] == true)
            shop_exists = "True"
          else
            shop_exists = "False"
          end
        else
          shop_exists = "NA"
        end

        if product.present? == false
          product_exists = "False"
        elsif (product.present? and product.name.present? and product.photo_file_name.present? and product.brand_id.present?)
          product_exists = "True"
        else 
        product_exists = "NA"
        end
        # if product
        #   csvProductPath.push([row['barcode'], row['retailer_id'], true])
        # else
        #   csvProductPath.push([row['barcode'], row['retailer_id'], false])
        # end
        # if product_in_shop
          csvShopPath.push([row['barcode'], row['retailer_id'], shop_exists, product_exists])
        # else
        #   csvShopPath.push([row['barcode'], row['retailer_id'], false])
        # end
      end
    end

    self.insertDataIntoCsv(@csvShopPath, csvShopHeaders, csvShopPath )
    # self.insertDataIntoCsv(@csvProductPath, csvProductHeaders, csvProductPath)

    csvShopData = File.open(@csvShopPath)
    # csvProductData = File.open(@csvProductPath)

    csvRecord.shop_csv = csvShopData
    csvRecord.shop_csv.instance_write(:content_type, 'text/csv')
    # csvRecord.product_csv = csvProductData
    # csvRecord.product_csv.instance_write(:content_type, 'text/csv')
    csvRecord.save!

    csvShopData.close
    # csvProductData.close
end
  private

  def self.insertDataIntoCsv(path, headers, data)
    CSV.open(path, "wb") do |csv|
      csv << headers
      data.each do |row|
        csv << row
      end
    end
  end

end
