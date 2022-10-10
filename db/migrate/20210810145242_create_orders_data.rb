class CreateOrdersData < ActiveRecord::Migration[5.1]
  def change
    create_table :orders_data do |t|
      t.integer :order_id
      t.jsonb :detail, default: {}

      t.timestamps null: false
    end
    add_index :orders_data, :order_id
  end
end
