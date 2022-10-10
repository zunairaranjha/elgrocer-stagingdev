class AddSmilesColumnsToShopper < ActiveRecord::Migration[5.1]
  def change
    add_column :shoppers, :smiles_loyalty_id, :string
    add_column :shoppers, :unique_smiles_token, :string
    add_column :shoppers, :retry_otp_attempts, :integer, default: 0
    add_column :shoppers, :invalid_otp_count, :integer, default: 0
    add_column :shoppers, :is_smiles_user, :boolean, default: false
  end
end
