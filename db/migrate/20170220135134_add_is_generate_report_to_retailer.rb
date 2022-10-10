class AddIsGenerateReportToRetailer < ActiveRecord::Migration
  def change
    add_column :retailers, :is_generate_report, :boolean, default: false
  end
end
