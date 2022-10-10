class CreateLocations < ActiveRecord::Migration
  def up
    create_table :locations do |t|
        t.string :name
    end
    execute 'ALTER TABLE locations ADD COLUMN created_at timestamp with time zone NOT NULL DEFAULT now()'
    execute 'ALTER TABLE locations ADD COLUMN updated_at timestamp with time zone NOT NULL DEFAULT now()'
  end
  def down
    drop_table :locations
  end
end
