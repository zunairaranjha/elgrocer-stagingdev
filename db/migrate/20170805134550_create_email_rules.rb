class CreateEmailRules < ActiveRecord::Migration
  def change
    create_table :email_rules do |t|
      t.string :name
      t.integer :days_for
      t.boolean :is_enable
      t.string :send_time
      t.integer :promotion_code_id

      t.timestamps null: false
    end
  end
end
