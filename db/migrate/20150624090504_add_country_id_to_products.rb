class AddCountryIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :country_gec, :string
  end
end
