class CreateRetailerOperators < ActiveRecord::Migration
  def up
    create_table :retailer_operators do |t|
      t.integer   :retailer_id, index: true, null: true
      t.string    :hardware_id
      t.string    :registration_id
      t.integer   :device_type
      t.timestamps
    end
  end

  def down
    drop_table :retailer_operators
  end
end
