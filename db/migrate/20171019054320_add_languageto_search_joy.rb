class AddLanguagetoSearchJoy < ActiveRecord::Migration
  def change
      add_column :searchjoy_searches, :language, :string
  end
end
