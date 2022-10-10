# This table stores details of products import Date: 11 Oct 2016
class ProductCsvImport < ActiveRecord::Base

  has_attached_file :csv_imports, :s3_headers => { "Content-Disposition" => "attachment; filename=import_rows.csv", "Content-Type" => "text/csv; application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; application/vnd.ms-excel;" }

  validate :check_utf8_format, unless: -> { csv_imports.queued_for_write[:original].blank? }, on: :create
  validates_attachment_presence :csv_imports
  validates_attachment_content_type :csv_imports, :content_type => ['text/plain', 'text/csv', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  has_attached_file :csv_failed_data, :s3_headers => { "Content-Disposition" => "attachment; filename=failed_import_rows.csv", "Content-Type" => "text/csv" }
  validates_attachment_content_type :csv_failed_data, :content_type => ['text/plain', 'text/csv', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  has_attached_file :csv_successful_data, :s3_headers => { "Content-Disposition" => "attachment; filename=successful_import_rows.csv", "Content-Type" => "text/csv" }
  validates_attachment_content_type :csv_successful_data, :content_type => ['text/plain', 'text/csv', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  def check_utf8_format
    file = open(csv_imports.queued_for_write[:original].path)

    unless file.all? { |line| Iconv.conv('UTF-8//IGNORE', 'UTF-8', line) == line }
      errors.add(:product_csv_import, 'file isnt utf-8')
      raise InvalidCsvFormatError
    end
  end
end
