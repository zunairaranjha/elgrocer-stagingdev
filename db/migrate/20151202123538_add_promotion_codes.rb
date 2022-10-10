class AddPromotionCodes < ActiveRecord::Migration
  def change
    create_table :promotion_codes do |t|
      t.integer :value_cents, default: 0
      t.string :value_currency, default: 'AED'
      t.string :code, null: false
      t.integer :allowed_realizations, default: 1
      t.datetime :start_date
      t.datetime :end_date
      t.integer :status
    end
  end
end
