# frozen_string_literal: true

require 'iconv'

ActiveAdmin.register RetailerReport do
  menu parent: 'Retailers' #, label: I18n.t('retailer_reports', scope: 'activerecord.labels.retailer')
  #permit_params :csv_import, :retailer_id, :admin_id, :import_table
  actions :all, except: [:edit, :update, :create, :new]

  #filter :name #retailer_company_name_cont, as: :string
  controller do
    def scoped_collection
      super.includes :retailer
    end
  end

  index title: 'Retailer Reports' do
    # panel 'General information', id: 'foo-panel' do
    #   span do
    #     "Retailer Reports"
    #   end
    # end
    column :name
    column :retailer_name do |obj|
      link_to(obj.retailer.company_name, admin_retailer_path(obj.retailer_id)) rescue 'Not found'
    end
    column :summery do |obj|
      link_to(obj.file1_file_name, obj.file1.url) rescue 'Not found'
    end
    column :detail do |obj|
      link_to(obj.file2_file_name, obj.file2.url) rescue 'Not found'
    end
    column :export_total do |obj|
      obj.export_total > 0 ? link_to(obj.export_total.to_s, obj.excel.url) : 0.to_s rescue 'Not found'
    end
    column :from_date
    column :to_date
    # actions
  end

  # form html: { enctype: 'multipart/form-data' } do |f|
  #   f.inputs 'Basic details' do
  #     f.input :retailer
  #     f.input :csv_import, as: :file
  #   end
  #   f.actions
  # end

  # controller do
  #   def scoped_collection
  #     super.includes :retailer
  #   end

  # end
end
