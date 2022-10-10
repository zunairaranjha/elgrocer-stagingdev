class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.references :shopper, index: true
      t.string :card_type
      t.string :last4
      t.string :country
      t.string :first6
      t.integer :expiry_month
      t.integer :expiry_year
      t.string :trans_ref
      t.boolean :is_deleted, default: false

      t.timestamps null: false
    end
    add_foreign_key :credit_cards, :shoppers
  end
end
