class ChangeComanyToCompany < ActiveRecord::Migration
  def change
    rename_column :retailers, :comany_name, :company_name
    rename_column :retailers, :comany_address, :company_address
  end
end
