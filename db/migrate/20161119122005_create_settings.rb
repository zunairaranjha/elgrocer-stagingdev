class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.boolean :enable_es_search, default: false
      t.timestamps null: false
    end
  end
end
