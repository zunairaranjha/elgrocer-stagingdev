class AddExcelFileToRetailerReports < ActiveRecord::Migration
  def change
    add_attachment :retailer_reports, :excel
  end
end
