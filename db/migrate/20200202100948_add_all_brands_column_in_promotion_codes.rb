class AddAllBrandsColumnInPromotionCodes < ActiveRecord::Migration
  def change
    add_column :promotion_codes, :all_brands, :boolean, default: false
    add_column :promotion_codes, :all_retailers, :boolean, default: false
  end
end
