class CreateOrdersAndOrderPositions < ActiveRecord::Migration
  def up
    create_table :orders do |t|
      t.belongs_to :retailer, index: true
      t.belongs_to :shopper, index: true
      t.datetime :created_at
    end

    execute "ALTER TABLE orders ALTER COLUMN created_at SET DEFAULT now()"

    create_table :order_positions do |t|
        t.belongs_to :order, index: true
        t.belongs_to :product, index: true
        t.integer :amount, :null => false
        t.boolean :was_in_shop, :default => true
    end
  end

  def down
    drop_table :orders
    drop_table :order_positions
  end
end
