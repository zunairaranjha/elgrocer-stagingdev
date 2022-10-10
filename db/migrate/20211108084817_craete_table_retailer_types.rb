class CraeteTableRetailerTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :retailer_types do |t|
      t.string :name
      t.string :description
      t.string :bg_color, default: '#00FFFFFF'
      t.integer :priority
      t.jsonb :translations, default: {}

      t.timestamps null: false
    end

    add_column :retailers, :is_featured, :boolean, default: false
    add_column :store_types, :bg_color, :string, default: '#00FFFFFF'
  end
end
