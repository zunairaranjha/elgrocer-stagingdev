class CreateAnalytics < ActiveRecord::Migration
  def change
    create_table :analytics do |t|
      t.references :shopper, index: true
      t.integer :event_id

      t.timestamps null: false
    end
    add_foreign_key :analytics, :shoppers
  end
end
