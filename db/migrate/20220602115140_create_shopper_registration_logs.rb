class CreateShopperRegistrationLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :shopper_registration_logs do |t|
      t.integer :shopper_id
      t.string :owner_type, null: false
      t.integer :owner_id, null: false
      t.string :partner_name
      t.string :partner_description
      t.boolean :success
      t.jsonb :details, default: {}

      t.timestamps
    end
  end
end
