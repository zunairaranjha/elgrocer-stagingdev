# frozen_string_literal: true

# This resource is added to import products in database
# Date 11 Oct 2016

require 'iconv'

ActiveAdmin.register ProductCsvImport do
  menu parent: 'Products', label: I18n.t('products_imports', scope: 'activerecord.labels.retailer')
  permit_params :csv_imports, :admin_id, :import_table
  actions :all, except: [:edit]
  
  index title: I18n.t('products_imports', scope: 'activerecord.labels.retailer') do
    panel 'General information', id: 'foo-panel' do
      span do
        li "Headers (case-sensitive): barcode; brand_id; product_name; product_name_ar; product_description; product_description_ar; category_id; external_image_url; size_unit; size_unit_ar; promotion_only;"
        li "On update it will keep existing value if left blank"
        li "promotion_only is TRUE no Shop will be entertained only active promotions will be accounted"
      end
    end

    column :csvimport do |obj|
      link_to(obj.csv_imports_file_name, obj.csv_imports.url)
    end
    column :successful_inserts do |obj|
      obj.successful_inserts > 0 ? link_to(obj.successful_inserts.to_s, obj.csv_successful_data.url) : 0.to_s  rescue 'Not completed'
    end
    column :failed_inserts do |obj|
      obj.failed_inserts > 0 ? link_to(obj.failed_inserts.to_s, obj.csv_failed_data.url) : 0.to_s rescue 'Not completed'
    end
    column :created_at
    column :updated_at
    actions
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Basic details' do
      f.input :csv_imports, as: :file
    end
    f.actions
  end

  controller do

    def create
      is_file = !permitted_params[:product_csv_import][:csv_imports].blank?
      
      if is_file
        new_params = permitted_params[:product_csv_import]
        new_params = new_params.merge(admin_id: current_admin_user.id)
        new_params = new_params.merge(import_table: 'products')
        begin
          new_csv_import = ProductCsvImport.create!(new_params)
        rescue InvalidCsvFormatError
          redirect_to admin_product_csv_imports_path, flash: { error: 'ERROR: Incorrect file format. You must attach a file with UTF-8 encoding!' }
        end
        if new_csv_import
          Resque.enqueue(DigestProductCsvJob, new_csv_import.id)
          redirect_to admin_product_csv_imports_path
        end
      else
        redirect_to admin_product_csv_imports_path, flash: { notice: "You must attach a file!" } if !is_file
      end

    end
  end

end
