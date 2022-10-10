# frozen_string_literal: true

ActiveAdmin.register Setting do
  menu parent: "Settings"
  permit_params :enable_es_search, 
  :order_accept_duration, :order_enroute_duration, :order_delivered_duration, 
  :product_rank_days, :product_rank_orders_limit, :product_rank_date, :product_derank_date, :apn_certificate, :es_search_fields, :es_min_match, :feedback_duration,
  :product_most_selling_days, :product_trending_days, :ios_version, :android_version, :web_version

  actions :all, except: [:new,:destroy]
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
  index do
    column :enable_es_search
    column :order_accept_duration
    column :order_enroute_duration
    column :order_delivered_duration
    column :product_rank_days
    actions
  end

  # show do
  #  attributes_table do
  #    row :enable_es_search
  #    row :order_accept_duration
  #    row :order_enroute_duration
  #    row :order_delivered_duration
  #  end
  # end

  form html: { enctype: "multipart/form-data" } do |f|
    f.inputs "Basic Setting" do
      f.input :enable_es_search
    end
    f.inputs 'Slack Notifications' do
      f.input :order_accept_duration
      f.input :order_enroute_duration
      f.input :order_delivered_duration
    end
    f.inputs 'Product Rank' do
      f.input :product_rank_days
      f.input :product_rank_orders_limit
      f.input :product_rank_date, as: :datepicker
      f.input :product_derank_date, as: :datepicker
    end
    f.inputs 'APN Certificate' do
      f.input :apn_certificate, as: :file
    end
    f.inputs 'ElasticSearch' do
      f.input :es_search_fields, hint: 'name*^3, category_name*, subcategory_name*^2, brand_name*, description*, size_unit*'
      f.input :es_min_match, hint: '70'
    end
    f.inputs 'Order Feedbcack' do
      f.input :feedback_duration, hint: 'minutes: 120-2880'
    end
    f.inputs 'Top Selling' do
      f.input :product_most_selling_days, hint: 'Last N days (30) to get most selling products'
      f.input :product_trending_days, hint: 'Last N days (7) to get trending products'
    end
    f.inputs 'App Versions' do
      f.input :ios_version, hint: "Version numbers in comma separated string without (.) and spaces e.g. 1234567,1234567"
      f.input :android_version, hint: "Version numbers in comma separated string without (.) and spaces e.g. 1234567,1234567"
      f.input :web_version, hint: "Version numbers in comma separated string without (.) and spaces e.g. 1234567,1234567"
    end
    f.actions
  end
  
  controller do
    # def edit
    #   Setting.find(params[:id])
    # end

    def update
      # @setting = Setting.find(params[:id])
      # @setting.update_attribute(:enable_es_search, params[:setting][:enable_es_search])
      attrs = params[:setting][:apn_certificate]
      params[:setting][:apn_certificate] = attrs.read unless attrs.blank?
      super
    end
  end

end
