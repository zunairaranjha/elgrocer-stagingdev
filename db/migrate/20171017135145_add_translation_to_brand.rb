class AddTranslationToBrand < ActiveRecord::Migration
  def change
    add_column :brands, :name_ar, :string
  end
end
