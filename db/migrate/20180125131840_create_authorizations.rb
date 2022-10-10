class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.string :provider
      t.string :uid
      t.string :token
      t.integer :shopper_id
      t.string :secret

      t.timestamps
    end
    add_index :authorizations, :shopper_id
  end
end
