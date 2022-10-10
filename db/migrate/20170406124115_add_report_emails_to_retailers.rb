class AddReportEmailsToRetailers < ActiveRecord::Migration
  def change
    add_column :retailers, :report_emails, :string
  end
end
