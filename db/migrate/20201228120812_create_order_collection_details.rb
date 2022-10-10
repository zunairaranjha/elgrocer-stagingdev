class CreateOrderCollectionDetails < ActiveRecord::Migration[4.2]
  def change
    create_table :order_collection_details do |t|
      t.integer :order_id
      t.integer :collector_detail_id
      t.integer :vehicle_detail_id
      t.integer :pickup_location_id
      t.string :collector_status
      t.json :events, default: '{}'
      t.timestamps null: false
    end
  end
end
