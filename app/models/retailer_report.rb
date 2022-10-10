class RetailerReport < ActiveRecord::Base
  belongs_to :retailer, optional: true

  has_attached_file :file1, :s3_headers => {"Content-Disposition" => "attachment; ", "Content-Type" => "text/csv"}
  validates_attachment_content_type :file1, :content_type => ['text/plain', 'text/csv', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  has_attached_file :file2, :s3_headers => {"Content-Disposition" => "attachment; ", "Content-Type" => "text/csv"}
  validates_attachment_content_type :file2, :content_type => ['text/plain', 'text/csv', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  has_attached_file :excel, :s3_headers => {"Content-Disposition" => "attachment; ", "Content-Type" => "text/csv"}
  validates_attachment_content_type :excel, :content_type => ['text/plain', 'text/csv', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']
end
