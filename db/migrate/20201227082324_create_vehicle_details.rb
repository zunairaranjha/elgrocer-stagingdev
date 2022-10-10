class CreateVehicleDetails < ActiveRecord::Migration[4.2]
  def change
    create_table :vehicle_details do |t|
      t.string :plate_number
      t.integer :vehicle_model_id
      t.integer :color_id
      t.string :company
      t.integer :collector_id
      t.boolean :is_deleted, :default => false
      t.integer :shopper_id
      
      t.timestamps null: false
    end
  end
end
