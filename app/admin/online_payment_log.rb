# frozen_string_literal: true

ActiveAdmin.register OnlinePaymentLog do
  menu parent: "Orders"
  actions :all, except: [:new,:edit,:destroy]
  # permit_params :id, :order_id, :fort_id, :merchant_reference, :amount, :method, :status, :created_at, :updated_at

  filter :order_id, label: 'Order ID'
  filter :merchant_reference
  filter :fort_id, label: 'Fort ID'
  filter :amount
  filter :status
  filter :created_at

  controller do
    def scoped_collection
      super.includes :order
    end
  end

  index do
    column :order
    column :fort_id
    column :merchant_reference
    column :amount
    column :method
    column :status
    column :created_at
    actions do |opl|
      if opl.method == "CAPTURE" and opl.order.card_detail["ps"] == "adyen" and (opl.order.final_amount || 0) > opl.order.refunded_amount.to_i / 100.0
        link_to('Refund', new_admin_partial_refund_path("online_payment_log[order_id]" => opl.order_id,
           "online_payment_log[merchant_reference]" => opl.merchant_reference))
      end
    end
  end

  show do
    attributes_table do
      default_attribute_table_rows.each do |field|
        row field
      end
    end
  end
end
