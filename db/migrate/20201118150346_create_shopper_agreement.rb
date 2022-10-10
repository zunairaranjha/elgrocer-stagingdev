class CreateShopperAgreement < ActiveRecord::Migration
  def change
    create_table :shopper_agreements do |t|
      t.integer :shopper_id
      t.boolean :accepted
      t.text :agreement

      t.timestamps null: false
    end

    add_column :categories, :current_tags, :integer, array: true, :default => '{}'
  end
end
