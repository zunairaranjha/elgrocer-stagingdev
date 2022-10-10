class RemovePromotionCodeStatusField < ActiveRecord::Migration
  def change
    remove_column :promotion_codes, :status
  end
end
