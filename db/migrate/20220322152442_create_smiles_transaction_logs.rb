class CreateSmilesTransactionLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :smiles_transaction_logs do |t|
      t.string :event
      t.string :transaction_id
      t.string :transaction_ref_id
      t.integer :order_id
      t.integer :shopper_id
      t.string :conversion_rule
      t.float :transaction_amount
      t.jsonb :details, default: {}

      t.timestamps
    end
  end
end
