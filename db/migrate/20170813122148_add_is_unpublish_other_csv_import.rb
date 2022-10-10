class AddIsUnpublishOtherCsvImport < ActiveRecord::Migration
  def change
    add_column :csv_imports, :is_unpublish_other, :boolean
    add_column :csv_imports, :unpublish_exclude_categories, :string
  end
end
