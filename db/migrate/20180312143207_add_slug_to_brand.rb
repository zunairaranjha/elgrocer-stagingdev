class AddSlugToBrand < ActiveRecord::Migration
  def change
    add_column :brands, :slug, :string
  end
end
