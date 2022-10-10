class CreatePromotionCodeAvailablePaymentTypes < ActiveRecord::Migration
  def change
    create_table :promotion_code_available_payment_types, id: false do |t|
      t.integer :promotion_code_id
      t.integer :available_payment_type_id

    end
  end
end
