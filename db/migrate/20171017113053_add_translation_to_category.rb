class AddTranslationToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :name_ar, :string
    add_column :categories, :description, :string
    add_column :categories, :description_ar, :string
    add_attachment :categories, :logo1
  end
end
