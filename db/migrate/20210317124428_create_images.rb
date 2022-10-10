class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.string :record_type, null: false
      t.integer :record_id, null: false
      t.integer :priority, default: 1
      t.attachment :photo

      t.timestamps null: false
    end
  end
end
