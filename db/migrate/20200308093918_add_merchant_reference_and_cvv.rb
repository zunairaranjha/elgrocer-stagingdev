class AddMerchantReferenceAndCvv < ActiveRecord::Migration
  def change
    add_column :orders, :merchant_reference, :string
    add_column :credit_cards,:cvv, :integer
  end
end
