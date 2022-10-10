# frozen_string_literal: true

ActiveAdmin.register Banner do
  menu parent: "Brands"
  permit_params :title, :title_ar, :subtitle, :subtitle_ar, :desc, :desc_ar, :btn_text, :btn_text_ar, :color, :text_color, :group, :priority, :keywords, :banner_type,
  :start_date, :end_date, :preferences, :is_active, banner_links_attributes: [:id,:category_id,:subcategory_id,:brand_id,:priority,:photo, :banner_id,:_destroy], retailer_ids: []

  filter :title_or_title_ar_cont, label: 'Title'
  filter :subtitle_or_subtitle_ar_cont, label: 'SubTitle'
  filter :desc_or_desc_ar_cont, label: 'Description'
  filter :btn_text_or_btn_text_ar_cont, label: 'Button Text'
  filter :color
  filter :text_color
  # filter :category_id
  # filter :subcategory_id
  # filter :brand_id
  filter :group
  filter :priority
  filter :preferences
  filter :retailers_id_eq, label: 'Retailer ID'
  # filter :retailers_name_cont, label: 'Retailer Name'
  filter :is_active
  filter :start_date
  filter :end_date
  filter :created_at
  filter :updated_at

  index do
    # column :photo do |obj|
    #   image_tag(obj.photo.url(:icon))
    # end
    column :title
    column :subtitle
    column :desc
    column :btn_text
    column :color
    # column :category
    # column :subcategory
    # column :brand
    column :group
    column :priority
    column :retailers do |code|
      div(title: "#{code.retailers.pluck(:company_name)*(', ')}") do
        (code.retailers.pluck(:company_name)*(', ')).truncate(30)
      end
    end
    column :start_date
    column :end_date
    column :is_active
    actions
  end

  form do |f|
    f.object.start_date = resource.start_date.to_time - 4.hours if resource.start_date
    f.object.end_date = resource.end_date.to_time - 4.hours if resource.end_date
    f.inputs do
      f.input :title
      f.input :title_ar
      f.input :subtitle
      f.input :subtitle_ar
      f.input :desc
      f.input :desc_ar
      f.input :btn_text
      f.input :btn_text_ar
      f.input :keywords, hint: 'Enter comma separated keywords e.g. milk,butter,water'
      f.input :banner_type, as: :select, collection: Banner.banner_types.keys
      f.input :retailers, as: :select, collection: Retailer.opened.order(:company_name, :id)
      f.input :select_all_retailers, :as => :boolean, :label => 'Select All Retailers', :input_html => {:onclick => "$('#banner_retailers_input option').prop('selected', $('#select_all_retailers')[0].checked);", :id => "select_all_retailers"}
      f.input :color, as: :string, hint: 'cc0033'
      f.input :text_color, as: :string, hint: 'cc0033'
      f.input :group
      f.input :priority
      f.input :start_date, as: :datepicker # , datepicker_options: { dateFormat: "%y-%m-%d" }
      f.input :end_date, :as => :datepicker # , :value => :end_date.try(:strftime,'%y-%m-%d')
      # f.input :preferences, as: :json
      f.input :is_active
      f.has_many :banner_links, heading: "Banner Links", new_record: "Add New", name: false, allow_destroy: true do |cf|
        cf.input :category, as: :select, collection: controller.category_suggest.map { |s| [s.name_and_id, s.id] }
        cf.input :subcategory_id, as: :select, collection: controller.category_suggest.map { |c| [c.name, c.subcategories.map { |s| [s.name_and_id, s.id] }]}
        cf.input :brand, as: :select, collection: Brand.all.order(:name, :id).map { |s| [s.name_and_id, s.id] }
        cf.input :priority
        cf.input :photo, as: :file, :hint => image_tag(cf.object.photo.url(:medium), :height => '50')
      end
    end
    f.actions
  end

  show do
    attributes_table do
      default_attribute_table_rows.each do |field|
        row field
      end
      row :retailers do
        banner.retailers.pluck(:company_name)*(', ')
      end
      # panel "Banner Links" do
      #   attributes_table_for banner.banner_links do
      #     rows image_tag(:photo_url, :height => '100'), :category, :subcategory, :brand
      #   end
      # end
      panel "Banner Links" do
        table_for banner.banner_links do
          column :photo do |p|
            image_tag(p.photo.url(:medium), :height => '50') # if :photo
          end
          # image_column :photo, style: :icon
          column :category
          column :subcategory
          column :brand
          column :priority
        end
      end
    end
  end

  controller do
    def create
      params[:banner][:start_date] = params[:banner][:start_date].to_time + 4.hours
      params[:banner][:end_date] = params[:banner][:end_date].to_time + 4.hours
      super
    end

    def update
      params[:banner][:start_date] = params[:banner][:start_date].to_time + 4.hours
      params[:banner][:end_date] = params[:banner][:end_date].to_time + 4.hours
      super
    end

    def category_suggest
      @category_suggest ||= Category.includes(:subcategories).where(parent_id: nil).order(:name, :id)
    end
  end

end
