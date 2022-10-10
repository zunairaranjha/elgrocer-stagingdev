# frozen_string_literal: true

ActiveAdmin.register ProductSuggestion do
  menu parent: "Collections"
  permit_params :name, :retailer_id,:shopper_id
  index do
    column :name
    column :retailer_id
    column :shopper_id
    column :created_at
    actions
  end
  filter :name
  filter :shopper_id, label: 'Shopper ID'
  filter :retailer_id, label: 'Retailer ID'
  filter :shopper_name_cont, as: :string, label: I18n.t(:shopper_name, :scope => ["activerecord", "labels", "order"])
  filter :retailer_company_name_cont, as: :string, label: I18n.t(:retailer_company_name, :scope => ["activerecord", "labels", "order"])


end
