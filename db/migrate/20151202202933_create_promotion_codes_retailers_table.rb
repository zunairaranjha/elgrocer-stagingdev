class CreatePromotionCodesRetailersTable < ActiveRecord::Migration
  def change
    create_table :promotion_codes_retailers, id: false do |t|
      t.belongs_to :promotion_code, index: true
      t.belongs_to :retailer, index: true
    end
  end
end
