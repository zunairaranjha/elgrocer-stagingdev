class AddCategoryToEmailRules < ActiveRecord::Migration
  def change
    add_column :email_rules, :category, :string
  end
end
