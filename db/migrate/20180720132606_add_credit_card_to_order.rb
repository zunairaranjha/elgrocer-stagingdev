class AddCreditCardToOrder < ActiveRecord::Migration
  def change
    add_reference :orders, :credit_card, index: true
    add_foreign_key :orders, :credit_cards
    add_column :orders, :card_detail, :json
  end
end
