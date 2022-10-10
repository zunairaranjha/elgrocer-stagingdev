class CreatePartnerIntegrations < ActiveRecord::Migration
  def change
    create_table :partner_integrations do |t|
      t.integer :retailer_id, index: true, null: false
      t.string :api_url, index: true, null: false
      t.string :user_name
      t.string :password
      t.string :branch_code
      t.string :api_key
      t.integer :integration_type
      t.integer :min_stock, default: 3

      t.timestamps null: false
    end
  end
end