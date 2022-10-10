class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.string :title
      t.string :title_ar
      t.string :subtitle
      t.string :subtitle_ar
      t.string :desc
      t.string :desc_ar
      t.string :btn_text
      t.string :btn_text_ar
      t.string :color
      t.string :text_color
      t.integer :group
      t.integer :priority
      t.json :preferences, default: '{}'
      t.boolean :is_active, default: true
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false

      t.timestamps null: false
    end
  end
end
