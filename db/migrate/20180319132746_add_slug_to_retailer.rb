class AddSlugToRetailer < ActiveRecord::Migration
  def change
    add_column :retailers, :slug, :string
  end
end
