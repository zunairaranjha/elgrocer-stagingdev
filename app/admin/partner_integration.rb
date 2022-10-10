# frozen_string_literal: true

ActiveAdmin.register PartnerIntegration do
  menu parent: 'Retailers'

  permit_params :retailer_id, :api_url, :user_name, :password, :branch_code, :api_key, :integration_type, :min_stock,
                :promotional_min_stock

  controller do
    def scoped_collection
      super.includes :retailer
    end
  end

  form do |f|
    f.inputs do
      f.input :retailer
      f.input :api_url
      f.input :user_name
      f.input :password, :as => :string
      f.input :branch_code, label: 'BranchCode | RetailerDeliveryZone'
      f.input :api_key, label: 'ApiKey | Team'
      f.input :min_stock
      f.input :promotional_min_stock
      f.input :integration_type, as: :select, collection: PartnerIntegration.integration_types.select { |key, value| [0, 1, 2, 3, 7, 12, 13].include? value }.keys
    end
    f.actions
  end

  index do
    column :retailer
    column :api_url
    column :user_name
    column 'BranchCode | RetailerDeliveryZone' do |partner|
      partner.branch_code
    end
    column :api_key
    column :min_stock
    column :promotional_min_stock
    column :integration_type
    actions
  end

  show do |partner|
    attributes_table do
      row :retailer
      row :api_url
      row :user_name
      row :password
      row 'BranchCode | RetailerDeliveryZone' do
        partner.branch_code
      end
      row 'ApiKey | Team', &:api_key
      row :min_stock
      row :promotional_min_stock
      row :integration_type
    end
  end

end
