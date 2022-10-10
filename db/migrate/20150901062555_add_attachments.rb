class AddAttachments < ActiveRecord::Migration
  def up
    add_attachment :csv_imports, :csv_failed_data
    add_attachment :csv_imports, :csv_successful_data
  end

  def down
    drop_attachment :csv_imports, :csv_failed_data
    drop_attachment :csv_imports, :csv_successful_data
  end
end
