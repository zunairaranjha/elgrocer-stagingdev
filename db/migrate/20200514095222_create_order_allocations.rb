class CreateOrderAllocations < ActiveRecord::Migration
  def change
    create_table :order_allocations do |t|
      t.integer :order_id
      t.integer :employee_id
      t.integer :event_id
      t.references :owner, polymorphic: true
      t.boolean :is_active, default: true

      t.timestamp :created_at, null: false
    end

    add_index :order_allocations, :created_at, order: {created_at: :desc}
  end
end
