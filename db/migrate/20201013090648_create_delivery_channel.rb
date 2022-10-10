class CreateDeliveryChannel < ActiveRecord::Migration
  def change
    create_table :delivery_channels do |t|
      t.string :name

      t.timestamps null: false
    end

    add_column :orders, :delivery_channel_id, :integer, :default => 0
  end
end
