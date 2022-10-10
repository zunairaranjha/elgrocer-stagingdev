class AddIsPublishedToShop < ActiveRecord::Migration
  def change
    add_column :shops, :is_published, :boolean, default: true
  end
end
