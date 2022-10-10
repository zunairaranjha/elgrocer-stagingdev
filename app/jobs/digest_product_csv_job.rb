require 'resque/errors'
require 'open-uri'
require 'csv'

class DigestProductCsvJob
  @queue = :csv_import_queue

  def self.perform(csvImportRecordId)
    # This should iterate through csv file rows
    # and for each row it should find a corresponding product
    # and if product is not present then it will create the product in database

    # rowNumber = 0
    # successfulInserts = 0
    # failedInserts = 0

    csvRecord = ProductCsvImport.find(csvImportRecordId)

    if Rails.env.production? || Rails.env.staging?
      csv = open(csvRecord.csv_imports.url, "r:utf-8").read
    else
      csv = File.open(csvRecord.csv_imports.path, mode: 'r:bom|utf-8')
    end

    csvFailedPath = "#{Rails.root.to_s}/tmp/failed_rows.csv"
    csvSuccessPath = "#{Rails.root.to_s}/tmp/successful_rows.csv"

    csvFailedRows = []
    csvSuccessfulRows = []

    csvSuccessHeaders = %w[barcode brand_id product_name product_name_ar product_description product_description_ar category_id external_image_url size_unit size_unit_ar promotion_only err_msg]
    csvFailedHeaders = %w[barcode brand_id product_name product_name_ar product_description product_description_ar category_id external_image_url size_unit size_unit_ar promotion_only err_msg]

    if File.extname(csvRecord.csv_imports_file_name) == ".csv"
      csvObj = CSV.parse(csv, skip_blanks: true, headers: true, header_converters: -> (f) { f.delete(' ') })

      csvObj.each do |row|
        err_msg = ''
        # rowNumber = rowNumber + 1
        product = Product.unscoped.find_by(barcode: row['barcode']) || Product.new
        # if (row['dbid_for_update'].blank? or product.new_record?) and Product.find_by(barcode: row['barcode'])
        #   err_msg = 'update: dbid for verification is missing or incorrect'
        # end
        begin
          product.barcode = row['barcode'] if product.new_record?
          product.brand_id = row['brand_id'] unless row['brand_id'].blank?
          product.name = row['product_name'].try(:strip) unless row['product_name'].blank?
          product.description = row['product_description'].try(:strip).try(:titleize) unless row['product_description'].blank?
          product.subcategory_ids = row['category_id'].to_s.scan(/\d+/) unless row['category_id'].blank?
          product.size_unit = row['size_unit'].try(:strip) unless row['size_unit'].blank?
          product.photo = URI.parse(WEBrick::HTTPUtils.escape(row['external_image_url'].strip)) unless row['external_image_url'].blank?
          #for arabic version
          product.name_ar = row['product_name_ar'].try(:strip) unless row['product_name_ar'].blank?
          product.description_ar = row['product_description_ar'].try(:strip).try(:titleize) unless row['product_description_ar'].blank?
          product.size_unit_ar = row['size_unit_ar'].try(:strip) unless row['size_unit_ar'].blank?
          product.is_promotional = row['promotion_only'].downcase.try(:strip).eql?('true') unless row['promotion_only'].blank?
        rescue Exception => e
          err_msg = "#{e}"
        end

        csv_row = [row['barcode'], row['brand_id'], row['product_name'], row['product_name_ar'], row['product_description'], row['product_description_ar'], row['category_id'], row['external_image_url'], row['size_unit'], row['size_unit_ar'], row['promotion_only'], err_msg]

        if row['barcode'] and product and err_msg.blank?
          product.save rescue ''
          err_msg = product.new_record? ? 'new' : 'update'
          csvSuccessfulRows.push(csv_row)
          # successfulInserts = successfulInserts+1
        else
          csvFailedRows.push(csv_row)
          # failedInserts = failedInserts+1
        end
      end
    elsif File.extname(csvRecord.csv_imports_file_name) == ".xlsx"

      csvObj = Roo::Spreadsheet.open(csv)
      csvObj.each(barcode: 'barcode', brand_id: 'brand_id', name: 'product_name', name_ar: 'product_name_ar', description: 'product_description', description_ar: 'product_description_ar', subcategory_ids: 'category_id', size_unit: 'size_unit', size_unit_ar: 'size_unit_ar', photo: 'external_image_url') do |row|
        err_msg = ''
        # unless rowNumber == 0
        product = Product.find_by(barcode: row[:barcode])
        if !product.present?
          begin
            product = Product.new(row)
            product.photo = URI.parse(WEBrick::HTTPUtils.escape((row[:photo].to_s).strip)) unless row[:photo].nil?
          rescue Exception => e
            err_msg = "#{e}"
          end
        end

        csv_row = [row[:barcode], row[:brand_id], row[:name], row[:name_ar], row[:description], row[:description_ar], row[:subcategory_ids], row[:photo], row[:size_unit], row[:size_unit_ar]]

        if product.present? and product.new_record? and err_msg.blank?
          product.save

          csvSuccessfulRows.push(csv_row)
          # successfulInserts = successfulInserts+1
        else
          csvFailedRows.push(csv_row)
          # failedInserts = failedInserts+1
        end
        # end
        # rowNumber = rowNumber + 1
      end
    end

    csvRecord.successful_inserts = csvSuccessfulRows.count
    csvRecord.failed_inserts = csvFailedRows.count

    self.insertDataIntoCsv(csvSuccessPath, csvSuccessHeaders, csvSuccessfulRows)
    self.insertDataIntoCsv(csvFailedPath, csvFailedHeaders, csvFailedRows)

    csvFailedData = File.open(csvFailedPath)
    csvSuccessfulData = File.open(csvSuccessPath)

    csvRecord.csv_failed_data = csvFailedData
    csvRecord.csv_failed_data.instance_write(:content_type, 'text/csv')
    csvRecord.csv_successful_data = csvSuccessfulData
    csvRecord.csv_successful_data.instance_write(:content_type, 'text/csv')
    csvRecord.save!

    csvFailedData.close
    csvSuccessfulData.close
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
