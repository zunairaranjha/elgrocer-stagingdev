class PromotionCodeDatesChangeType < ActiveRecord::Migration
  def change
    change_column :promotion_codes, :start_date, :date
    change_column :promotion_codes, :end_date, :date
  end
end
