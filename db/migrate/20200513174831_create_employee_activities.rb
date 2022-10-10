class CreateEmployeeActivities < ActiveRecord::Migration
  def change
    create_table :employee_activities do |t|
      t.integer :employee_id
      t.integer :event_id
      t.integer :order_id

      t.timestamp :created_at, null: false
    end

    add_index :employee_activities, :created_at, order: {created_at: :desc}
  end
end
