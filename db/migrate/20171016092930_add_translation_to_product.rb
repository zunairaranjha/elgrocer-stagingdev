class AddTranslationToProduct < ActiveRecord::Migration
  def change
    add_column :products, :name_ar, :string
    add_column :products, :description_ar, :string
    add_column :products, :size_unit_ar, :string
  end
end
