class AddPromotionTypeAndJsonBDataToPromotionCode < ActiveRecord::Migration[5.1]
  def change
    add_column :promotion_codes, :promotion_type, :integer
    add_column :promotion_codes, :data, :jsonb, default: {}
  end
end
