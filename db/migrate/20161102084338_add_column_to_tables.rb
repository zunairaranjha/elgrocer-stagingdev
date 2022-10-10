class AddColumnToTables < ActiveRecord::Migration
  def change
    add_attachment :brands, :brand_logo_1
    add_attachment :brands, :brand_logo_2
    add_attachment :categories, :logo
  end
end
