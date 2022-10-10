# frozen_string_literal: true

require 'iconv'

ActiveAdmin.register CsvImport do
  menu parent: 'Retailers', label: I18n.t('products_imports', scope: 'activerecord.labels.retailer')
  permit_params :csv_import, :retailer_id, :admin_id, :import_table, :is_unpublish_other,:normalize_13_digits , :unpublish_exclude_categories,
                categories_attributes: %i[id name]
  actions :all, except: [:edit]

  # filter :retailer_company_name_cont, as: :string
  remove_filter :retailer

  controller do
    def scoped_collection
      resource_class.where(import_table: 'shops')
    end
  end

  index title: I18n.t('products_imports', scope: 'activerecord.labels.retailer') do
    panel 'General information', id: 'foo-panel' do
      span do
        li "Please make sure that the file you're importing has headers named exactly as follows:"
        li 'barcode; price; retailer_id; is_promotional; is_published; price_currency; standard_price; percentage_off; start_time; end_time; product_limit; promotion_only; enable_product'
        li 'percentage_off should be integer e.g for 10% it should be 10'
        li "'product_limit' 0 / blank means Unlimited"
        li "'start_time' and 'end_time' should be in Dubai Time Zone and 24hr time format like DD/MM/YYYY hh:mm"
        li '25/05/2021 09:00, 25/05/2021 18:00'
        li 'enable_product possible values (TRUE/FALSE) if blank default is FALSE'
      end
    end

    # column :retailer_name do |obj|
    #   link_to(obj.retailer.company_name, admin_retailer_path(obj.retailer_id)) rescue 'Not found'
    # end
    column :csvimport do |obj|
      link_to(obj.csv_import_file_name, obj.csv_import.url)
    end
    column :successful_inserts do |obj|
      obj.successful_inserts > 0 ? link_to(obj.successful_inserts.to_s, obj.csv_successful_data.url) : 0.to_s  rescue 'Not completed'
    end
    column :failed_inserts do |obj|
      obj.failed_inserts > 0 ? link_to(obj.failed_inserts.to_s, obj.csv_failed_data.url) : 0.to_s rescue 'Not completed'
    end
    column :is_unpublish_other
    column :created_at
    column :updated_at
    column :exclude_categories do |code|
      code.unpublish_exclude_categories.to_s.truncate(30)
    end
    actions
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Basic details' do
      # f.input :retailer
      f.input :csv_import, as: :file
      f.input :is_unpublish_other
      f.input :normalize_13_digits, as: :boolean
      f.input :unpublish_exclude_categories, as: :select, multiple: true, collection: Category.where('parent_id is null').order(:name).all.map { |c| [ c.name_and_id, c.id ] }
      li do
        link_to 'Select All Categories', '#csv_import_unpublish_exclude_categories', onclick: "$('#csv_import_unpublish_exclude_categories option').prop('selected', true);", :id => 'select_all_categories'
      end
    end
    f.actions
  end

  controller do
    # def scoped_collection
    #   super.includes :retailer
    # end

    def create
      is_file = !permitted_params[:csv_import][:csv_import].blank?
      unpublish_exclude_categories_ids = params[:csv_import][:unpublish_exclude_categories].select(&:present?).join(',') if params[:csv_import][:unpublish_exclude_categories].present?
      # is_retailer_id = !permitted_params[:csv_import][:retailer_id].blank?

      if is_file
        new_params = permitted_params[:csv_import]
        new_params = new_params.merge(admin_id: current_admin_user.id)
        new_params = new_params.merge(import_table: 'shops')
        new_params = new_params.merge(retailer_id: 0)
        # new_params = new_params.merge(is_unpublish_other: permitted_params[:is_unpublish_other])
        new_params = new_params.merge(unpublish_exclude_categories: unpublish_exclude_categories_ids) #if unpublish_exclude_categories_ids.present?
        begin
          new_csv_import = CsvImport.create!(new_params)
        rescue InvalidCsvFormatError
          redirect_to admin_csv_imports_path, flash: { error: 'ERROR: Incorrect file format. You must attach a file with UTF-8 encoding!' }
        end

        if new_csv_import
          Resque.enqueue(DigestShopCsvJob, new_csv_import.id, permitted_params[:csv_import][:normalize_13_digits])
          #DigestShopCsvJob.perform(new_csv_import.id)
          redirect_to admin_csv_imports_path
        end
      else
        redirect_to admin_csv_imports_path, flash: { notice: 'You must attach a file!' } unless is_file
        # redirect_to admin_csv_imports_path, flash: { notice: "You must select a retailer!" } if is_file && !is_retailer_id
        # redirect_to admin_csv_imports_path, flash: { notice: "Fields can't be blank!" } if !is_file && !is_retailer_id
      end

    end
  end
end
