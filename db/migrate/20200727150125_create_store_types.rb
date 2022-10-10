class CreateStoreTypes < ActiveRecord::Migration
  def change
    create_table :store_types do |t|
      t.string :name
      t.string :name_ar
      t.integer :priority
      t.attachment :photo

      t.timestamps null: false
    end

    create_table :retailer_store_types, id: false do |t|
      t.integer :retailer_id
      t.integer :store_type_id
    end
  end
end
