class CreateCollectorDetails < ActiveRecord::Migration[4.2]
  def change
    create_table :collector_details do |t|
      t.string :name
      t.string :phone_number
      t.integer :shopper_id
      t.boolean :is_deleted, :default => false
      
      t.timestamps null: false
    end
  end
end
