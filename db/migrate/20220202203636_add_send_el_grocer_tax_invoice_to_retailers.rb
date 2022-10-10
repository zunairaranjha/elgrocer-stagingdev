class AddSendElGrocerTaxInvoiceToRetailers < ActiveRecord::Migration[5.1]
  def change
    add_column :retailers, :send_tax_invoice, :boolean, default: false
  end
end
