class CreateAvailablePaymentTypes < ActiveRecord::Migration
  def up
    create_table :available_payment_types do |t|

    end
  end

  def down
    drop_table :available_payment_types
  end
end
