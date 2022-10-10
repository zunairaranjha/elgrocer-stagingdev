class AddReferenceToPromotionCode < ActiveRecord::Migration[5.1]
  def change
    add_column :promotion_codes, :reference, :string
  end
end
