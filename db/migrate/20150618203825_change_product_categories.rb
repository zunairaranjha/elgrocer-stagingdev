class ChangeProductCategories < ActiveRecord::Migration
  def up
    drop_table :product_categories

    create_table :product_categories do |t|
      t.integer :product_id
      t.integer :category_id
      t.timestamps null: false
    end
    remove_column :products, :product_category_id
  end
  def down
    drop_table :product_categories
    create_table :product_categories do |t|
      t.string   "name"
      t.integer  "parent_id"
      t.integer  "lft",                        null: false
      t.integer  "rgt",                        null: false
      t.integer  "depth",          default: 0, null: false
      t.integer  "children_count", default: 0, null: false
    end
    add_column :products, :product_category_id, :integer
  end
end
