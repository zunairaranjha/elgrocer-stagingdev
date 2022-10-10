class UpdateEmailIndexOnShopper < ActiveRecord::Migration[5.1]
  def change
    remove_index :shoppers, name: :index_shoppers_on_email, column: :email if index_exists?(:shoppers, :email, name: :index_shoppers_on_email)
    # remove_index :shoppers, name: :email_lower_idx, column: 'lower(email::text)' if index_exists?(:shoppers, 'lower(email::text)', name: :email_lower_idx)
    # remove_index :shoppers, name: :email_upper_idx, column: 'upper(email::text)' if index_exists?(:shoppers, 'upper(email::text)', name: :email_upper_idx)
    add_index :shoppers, :email, unique: true, where: "(email IS NOT NULL) AND (email != '')"
    # add_index :shoppers, 'lower(email::text)', unique: true, where: "(email IS NOT NULL) AND (email != '')", name: :email_lower_idx
    # add_index :shoppers, 'upper(email::text)', unique: true, where: "(email IS NOT NULL) AND (email != '')", name: :email_upper_idx
  end
end
