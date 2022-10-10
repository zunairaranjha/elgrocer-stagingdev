class CreatePaymentThresholds < ActiveRecord::Migration
  def change
    create_table :payment_thresholds do |t|
      t.integer :order_id
      t.integer :employee_id
      t.boolean :is_approved
      t.string  :rejection_reason

      t.timestamp :created_at, null: false
    end

    add_index :payment_thresholds, :created_at, order: {created_at: :desc}
  end
end
