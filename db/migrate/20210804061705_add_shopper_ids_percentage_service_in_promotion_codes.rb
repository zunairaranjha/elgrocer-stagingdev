class AddShopperIdsPercentageServiceInPromotionCodes < ActiveRecord::Migration[5.1]
  def change
    add_column :promotion_codes, :shopper_ids, :integer, array: true, :default => '{}'
    add_column :promotion_codes, :percentage_off, :float
    add_column :promotion_codes, :retailer_service_id, :integer
    add_column :promotion_code_realizations, :discount_value, :integer
  end
end
