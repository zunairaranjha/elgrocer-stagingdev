# frozen_string_literal: true

ActiveAdmin.register ShopPromotion do
  menu parent: 'Products', label: 'Shop Promotions'
  includes :retailer

  actions :all, except: [:delete]
  # includes :categories, :product_categories, :subcategories, :brand, :product, :retailer
  permit_params :price_currency, :product_id, :retailer_id, :start_time, :end_time, :standard_price, :price, :product_limit, :time_of_start, :time_of_end, :is_active

  controller do
    def scoped_collection
      ShopPromotion.unscoped
    end
  end

  filter :retailer_id_equals, label: 'retailer_id'
  filter :retailer_company_name_cont, as: :string
  filter :product_id, label: 'product_id'
  filter :created_at
  filter :updated_at

  index do
    column :id
    column :retailer
    column :product_id
    column :time_of_start
    column :time_of_end
    column :standard_price
    column :price, label: :promotional_price
    column :product_limit
    column :is_active
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :retailer
      row :product
      row :time_of_start
      row :time_of_end
      row :standard_price
      row :price
      row :product_limit
      row :is_active
      row :created_at
      row :updated_at
    end
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Basic details' do
      f.input :retailer, collection: Retailer.pluck(:company_name, :id)
      f.input :product_id
      f.input :time_of_start, as: :date_time_picker, hint: 'Time should be according to Dubai Time Zone'
      f.input :time_of_end, as: :date_time_picker, hint: 'Time should be according to Dubai Time Zone'
      f.input :standard_price, hint: 'If given system will set this as standard price. Other wise follow the rule to set standard price.'
      f.input :price
      f.input :price_currency
      f.input :product_limit, hint: '0 - Unlimited'
      f.input :is_active
    end
    f.actions
  end

  controller do
    def create
      set_params
      super
    end

    def update
      set_params
      super
    end

    def set_params
      params[:shop_promotion][:start_time] = (params[:shop_promotion][:time_of_start].to_s.to_time.utc.to_f * 1000).floor
      params[:shop_promotion][:end_time] = (params[:shop_promotion][:time_of_end].to_s.to_time.utc.to_f * 1000).floor
    end
  end
end
