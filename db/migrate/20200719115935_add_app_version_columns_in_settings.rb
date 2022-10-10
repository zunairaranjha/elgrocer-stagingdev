class AddAppVersionColumnsInSettings < ActiveRecord::Migration
  def change
    add_column :settings, :ios_version, :string
    add_column :settings, :android_version, :string
    add_column :settings, :web_version, :string
  end
end
