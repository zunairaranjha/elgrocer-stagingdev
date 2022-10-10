class CreateCampaigns < ActiveRecord::Migration[5.1]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :name_ar
      t.datetime :start_time
      t.datetime :end_time
      t.integer :priority
      t.integer :campaign_type
      t.integer :category_ids, array: true, :default => '{}'
      t.integer :subcategory_ids, array: true, :default => '{}'
      t.integer :brand_ids, array: true, :default => '{}'
      t.integer :retailer_ids, array: true, :default => '{}'
      t.integer :store_type_ids, array: true, :default => '{}'
      t.integer :retailer_group_ids, array: true, :default => '{}'
      t.integer :product_ids, array: true, :default => '{}'
      t.integer :locations, array: true, :default => '{}'
      t.string :keywords, array: true, default: []
      t.string :url
      t.attachment :photo
      t.attachment :photo_ar
      t.attachment :banner
      t.attachment :banner_ar
      t.attachment :web_photo
      t.attachment :web_photo_ar
      t.attachment :web_banner
      t.attachment :web_banner_ar

      t.timestamps null: false
    end
  end
end
