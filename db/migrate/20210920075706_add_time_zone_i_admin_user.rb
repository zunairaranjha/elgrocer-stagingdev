class AddTimeZoneIAdminUser < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_users, :current_time_zone, :string
  end
end
