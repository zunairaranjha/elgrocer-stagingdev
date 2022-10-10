class UpdatePromotionCodeStartDateDefault < ActiveRecord::Migration
  def change
    change_column_default :promotion_codes, :start_date, Time.zone.now
  end
end
