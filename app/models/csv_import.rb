class CsvImport < ActiveRecord::Base
  belongs_to :retailer, optional: true
  validate :check_utf8_format, unless: -> { csv_import.queued_for_write[:original].blank? }, on: :create
  attr_accessor :normalize_13_digits

  has_attached_file :csv_import, :s3_headers => { "Content-Disposition" => "attachment; filename=import_rows.csv", "Content-Type" => "text/csv; application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; application/vnd.ms-excel;" }
  validates_attachment_presence :csv_import
  # validates_attachment_content_type :csv_import, :content_type => ['text/csv', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']
  validates_attachment_content_type :csv_import, :content_type => ['text/plain', 'text/csv', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  has_attached_file :csv_failed_data, :s3_headers => { "Content-Disposition" => "attachment; filename=failed_import_rows.csv", "Content-Type" => "text/csv" }

  validates_attachment_content_type :csv_failed_data, :content_type => ['text/plain', 'text/csv', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  has_attached_file :csv_successful_data, :s3_headers => { "Content-Disposition" => "attachment; filename=successful_import_rows.csv", "Content-Type" => "text/csv" }

  validates_attachment_content_type :csv_successful_data, :content_type => ['text/plain', 'text/csv', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  def check_utf8_format
    file = open(csv_import.queued_for_write[:original].path)

    unless file.all? { |line| Iconv.conv('UTF-8//IGNORE', 'UTF-8', line) == line }
      errors.add(:csv_import, 'file isnt utf-8')
      raise InvalidCsvFormatError
    end
  end
end
