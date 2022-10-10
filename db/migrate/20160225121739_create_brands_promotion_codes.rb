class CreateBrandsPromotionCodes < ActiveRecord::Migration
  def up
    create_table :brands_promotion_codes, id: false do |t|
      t.belongs_to :promotion_code, index: true
      t.belongs_to :brand, index: true
    end

    PromotionCode.find_each do |promotion_code|
      promotion_code.brands = Brand.all
      promotion_code.save!
    end
  end

  def down
    drop_table :brands_promotion_codes
  end
end
