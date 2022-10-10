class CreateUserPlatformLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :user_platform_logs do |t|
      t.integer :shopper_id
      t.integer :device_type
      t.integer :platform_type
      t.string :app_version

      t.timestamps
    end
  end
end
