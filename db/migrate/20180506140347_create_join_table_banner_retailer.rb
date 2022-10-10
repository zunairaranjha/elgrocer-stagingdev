class CreateJoinTableBannerRetailer < ActiveRecord::Migration
  def change
    create_join_table :banners, :retailers do |t|
      # t.index [:banner_id, :retailer_id]
      # t.index [:retailer_id, :banner_id]
    end
  end
end
