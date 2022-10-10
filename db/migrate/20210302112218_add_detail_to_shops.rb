class AddDetailToShops < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :detail, :json, default: {}
  end
end
