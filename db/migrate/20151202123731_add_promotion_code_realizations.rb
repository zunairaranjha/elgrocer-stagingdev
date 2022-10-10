class AddPromotionCodeRealizations < ActiveRecord::Migration
  def change
    create_table :promotion_code_realizations do |t|
      t.belongs_to :promotion_code, index: true
      t.belongs_to :shopper, index: true
      t.belongs_to :order, index: true
      t.datetime :realization_date, null: false
    end
  end
end
