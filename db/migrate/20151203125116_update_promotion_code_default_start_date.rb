class UpdatePromotionCodeDefaultStartDate < ActiveRecord::Migration
  def change
    change_column_default :promotion_codes, :start_date, nil
  end
end
