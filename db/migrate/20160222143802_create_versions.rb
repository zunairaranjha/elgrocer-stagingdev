class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.integer :majorversion, null: false
      t.integer :minorversion, null: false
      t.integer :revision, null: false
      t.integer :devise_type
      t.integer :action, null: false, default: 0
      t.string  :message
      t.timestamps
    end
  end
end
