class AddColumnsToRetailer < ActiveRecord::Migration
  def change
    add_column :retailers, :is_report_add_email, :boolean, default: false
    add_column :retailers, :is_report_add_phone, :boolean, default: false
  end
end
