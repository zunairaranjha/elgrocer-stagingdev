# frozen_string_literal: true

require 'iconv'

ActiveAdmin.register CsvImport, as: "shop_promotion_csv_import" do
  menu parent: 'Retailers', label: 'Shop Promotion Import'
  permit_params :csv_import, :retailer_id, :admin_id, :import_table

  actions :all, except: [:edit]

  filter :created_at
  filter :updated_at
  filter :csv_import_file_name

  controller do
    def scoped_collection
      resource_class.where(import_table: 'shop_promotions')
    end
  end

  index title: 'Shop Promotion Import' do
    panel 'General information', id: 'foo-panel' do
      span do
        li "Please make sure that the file you're importing has headers named exactly as follows: barcode; standard_price; price; price_currency; product_limit; retailer_id; start_time; end_time;"
        li "'price' is promotional price"
        li "'product_limit' 0 - Unlimited"
        li "'start_time' and 'end_time' should be in Dubai Time Zone and 24hr time format like DD/MM/YYYY hh:mm"
        li "25/05/2021 09:00, 25/05/2021 18:00"
      end
    end

    column :csvimport do |obj|
      link_to(obj.csv_import_file_name, obj.csv_import.url)
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
      f.input :csv_import, as: :file
    end
    f.actions
  end

  controller do

    def create
      is_file = permitted_params[:csv_import][:csv_import].present?

      if is_file
        new_params = permitted_params[:csv_import]
        new_params = new_params.merge(admin_id: current_admin_user.id)
        new_params = new_params.merge(import_table: 'shop_promotions')
        new_params = new_params.merge(retailer_id: 0)
        begin
          new_csv_import = CsvImport.create!(new_params)
        rescue InvalidCsvFormatError
          redirect_to admin_shop_promotion_csv_imports_path, flash: { error: 'ERROR: Incorrect file format. You must attach a file with UTF-8 encoding!' }
        end

        if new_csv_import
          Resque.enqueue(DigestShopPromotionJob, new_csv_import.id)
          redirect_to admin_shop_promotion_csv_imports_path
        end
      else
        redirect_to admin_shop_promotion_csv_imports_path, flash: { notice: "You must attach a file!" } unless is_file
      end

    end
  end
end
