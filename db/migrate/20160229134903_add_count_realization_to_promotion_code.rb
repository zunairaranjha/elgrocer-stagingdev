class AddCountRealizationToPromotionCode < ActiveRecord::Migration
  def change
    add_column :promotion_codes, :realizations_per_shopper, :integer, default: 1
    add_column :promotion_codes, :realizations_per_retailer, :integer, default: 1
  end
end
