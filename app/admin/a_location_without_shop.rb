# frozen_string_literal: true

ActiveAdmin.register ALocationWithoutShop do
  menu parent: "Collections"
  actions :all, except: [:new,:edit,:destroy]
  remove_filter :shopper
  includes :shopper
  # actions :index, :show

  show do
    attributes_table do
      default_attribute_table_rows.each do |field|
        row field
      end

      # Custom bits here

    end
  end
end
