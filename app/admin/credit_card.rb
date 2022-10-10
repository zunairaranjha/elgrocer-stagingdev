# frozen_string_literal: true

ActiveAdmin.register CreditCard do
  menu parent: "Shoppers"
  actions :all, except: [:new,:edit,:destroy]
  # actions :index, :show

  remove_filter :shopper
  remove_filter :orders

  show do
    attributes_table do
      default_attribute_table_rows.each do |field|
        row field
      end

    end
  end
end
