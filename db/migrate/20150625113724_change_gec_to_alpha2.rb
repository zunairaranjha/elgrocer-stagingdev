class ChangeGecToAlpha2 < ActiveRecord::Migration
  def change
    rename_column :products, :country_gec, :country_alpha2
  end
end
