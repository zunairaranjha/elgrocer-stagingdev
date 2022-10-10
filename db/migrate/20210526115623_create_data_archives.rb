class CreateDataArchives < ActiveRecord::Migration[5.1]
  def change
    create_table :data_archives do |t|
      t.integer :owner_id
      t.string :owner_type
      t.jsonb :detail, default: {}
      t.timestamp :created_at, null: false
    end
  end
end
