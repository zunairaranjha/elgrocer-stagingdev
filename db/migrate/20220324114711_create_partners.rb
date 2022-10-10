class CreatePartners < ActiveRecord::Migration[5.1]
  def change
    create_table :partners do |t|
      t.string :name
      t.jsonb :config, :default => {}
      t.integer :partner_configuration_id
      
      t.timestamps
    end
  end
end
