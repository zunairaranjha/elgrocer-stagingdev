class AddDefaultValueToPromotionTypeInPromotionCodes < ActiveRecord::Migration[5.1]
  def up
    change_column :promotion_codes, :promotion_type, :integer, default: 4
  end

  def down
    change_column :promotion_codes, :promotion_type, :integer, default: nil
  end
end
