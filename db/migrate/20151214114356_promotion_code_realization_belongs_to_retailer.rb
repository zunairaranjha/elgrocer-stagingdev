class PromotionCodeRealizationBelongsToRetailer < ActiveRecord::Migration
  def change
    change_table :promotion_code_realizations do |t|
      t.belongs_to :retailer, index: true
    end
  end
end
