class AddOrderLimitToPromotionCodes < ActiveRecord::Migration
  def change
    add_column :promotion_codes, :order_limit, :string, default: '0'
  end
end
