class CreateCarouselProducts < ActiveRecord::Migration
  def change
    create_table :carousel_products do |t|
      t.string :product_ids, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false

      t.timestamps null: false
    end
  end
end
