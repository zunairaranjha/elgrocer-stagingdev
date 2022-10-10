# frozen_string_literal: true

require 'iconv'

ActiveAdmin.register MustStockList do
  menu parent: 'Retailers', label: I18n.t('must_stock_list', scope: 'activerecord.labels.retailer')
  permit_params :csv_import
  actions :all, except: [:edit]

  # filter :retailer_company_name_cont, as: :string

  index title: I18n.t('must_stock_list', scope: 'activerecord.labels.retailer') do
    panel 'General information', id: 'foo-panel' do
      span do
        "Please make sure that the file you're importing has headers named exactly as follows: barcode; retailer_id;"
      end
    end
    column :csvimport do |obj|
      link_to(obj.csv_import_file_name, obj.csv_import.url)
    end
    column :shop_csv do |obj|
      obj.shop_csv.present? ? link_to(obj.shop_csv_file_name, obj.shop_csv.url) :  'Not completed'  rescue 'Not completed'
    end
    # column :product_csv do |obj|
    #   obj.product_csv.present? ? link_to(obj.product_csv_file_name, obj.product_csv.url) : 'Not completed' rescue 'Not completed'
    # end
     actions
   end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Basic details' do
      f.input :csv_import, as: :file
    end
    f.actions
  end

  controller do
    # def scoped_collection
    #   super.includes :retailer
    # end

    def create
      is_file = !permitted_params[:must_stock_list][:csv_import].blank?
      if is_file
        begin
          new_params = permitted_params[:must_stock_list]
          new_csv_import = MustStockList.create!(new_params)
        rescue InvalidCsvFormatError
          redirect_to admin_must_stock_lists_path, flash: { error: 'ERROR: Incorrect file format. You must attach a file with UTF-8 encoding!' }
        end

        if new_csv_import
          Resque.enqueue(MustStockListJob, new_csv_import.id)
          #DigestShopCsvJob.perform(new_csv_import.id)
          redirect_to admin_must_stock_lists_path
        end
      else
        redirect_to admin_must_stock_lists_path, flash: { notice: "You must attach a file!" } if !is_file
        # redirect_to admin_csv_imports_path, flash: { notice: "You must select a retailer!" } if is_file && !is_retailer_id
        # redirect_to admin_csv_imports_path, flash: { notice: "Fields can't be blank!" } if !is_file && !is_retailer_id
      end

    end
  end
end
