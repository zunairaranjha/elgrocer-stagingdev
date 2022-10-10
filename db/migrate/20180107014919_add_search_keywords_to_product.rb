class AddSearchKeywordsToProduct < ActiveRecord::Migration
  def change
    add_column :products, :search_keywords, :string
  end
end
