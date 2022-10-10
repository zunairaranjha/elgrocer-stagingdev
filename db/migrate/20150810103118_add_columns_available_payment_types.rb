class AddColumnsAvailablePaymentTypes < ActiveRecord::Migration
  def change
    add_column :available_payment_types, :name, :string
    add_column(:available_payment_types, :created_at, :datetime)
    add_column(:available_payment_types, :updated_at, :datetime)
  end
end
