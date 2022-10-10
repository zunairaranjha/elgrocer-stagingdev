# frozen_string_literal: true

ActiveAdmin.register Screen do
  menu parent: "Custom Screen"
  # includes :retailers
  permit_params :id, :name, :priority, :group, :is_active, :photo, :photo_ar, :banner_photo, :banner_photo_ar, :locations, :store_types, :start_date, :end_date, :retailer_ids, :screen_product_ids,
                :retailer_groups, :select_all_retailers, screen_products_attributes: [:id, :screen_id, :product_id, :priority, :_destroy], product_ids: []
  #, :screen_retailer_ids
  # remove_filter :retailers, :screen_retailers, :products, :screen_products, :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at, :photo_ar_file_name, :photo_ar_content_type, :photo_ar_file_size, :photo_ar_updated_at,
  # :banner_photo_file_name, :banner_photo_content_type, :banner_photo_file_size, :banner_photo_updated_at, :banner_photo_ar_file_name, :banner_photo_ar_content_type, :banner_photo_ar_file_size, :banner_photo_ar_updated_at

  form html: { enctype: "multipart/form-data" } do |f|
    # f.object.screen_retailer_ids = resource.retailers.ids.join(',')
    f.object.screen_product_ids = resource.products.ids.join(',')
    f.object.store_types_ids = resource.store_types.join(',')
    f.object.retailer_groups = resource.retailer_groups.join(',')
    f.object.retailer_ids = resource.retailer_ids.join(',')
    f.object.start_date = resource.start_date.to_time - 4.hours if resource.end_date
    f.object.end_date = resource.end_date.to_time - 4.hours if resource.end_date
    f.inputs "Basic details" do
      f.input :name
      f.input :priority
      f.input :group
      f.input :is_active
      f.input :photo, as: :file
      f.input :photo_ar, as: :file
      f.input :banner_photo, as: :file
      f.input :banner_photo_ar, as: :file
      f.input :locations, as: :check_boxes, collection: controller.loca
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      # f.input :retailers, collection: Retailer.where(is_active: true).pluck(:company_name, :id)
      f.input :store_types_ids, as: :string
      f.input :retailer_groups, as: :string
      f.input :retailer_ids, label: 'Retailers', as: :string
      f.input :select_all_retailers, :as => :boolean, :label => 'Select All Retailers', :input_html => { :onclick => "$('#screen_retailer_ids option').prop('selected', $('#select_all_retailers')[0].checked);", :id => "select_all_retailers" }
      f.input :screen_product_ids, label: 'Products', as: :string
      # f.has_many :screen_products, heading: "Products", new_record: "Add New", name: false, allow_destroy: true do |cf|
      #   cf.input :product_id, as: :search_select, url: admin_search_products_path,
      #            fields: [:name, :id], display_name: "full_name", minimum_input_length: 3,
      #            order_by: 'size_unit_asc'
      #   cf.input :priority
      # end
    end
    f.actions
  end

  index do
    column :id
    column :name
    column :group
    column :priority
    column :retailer_ids do |code|
      (code.retailer_ids.join(',')).truncate(30)
    end
    # column :retailers do |code|
    #   div(title: "#{code.retailers.pluck(:company_name)*(', ')}") do
    #     (code.retailers.pluck(:company_name)*(', ')).truncate(30)
    #   end
    # end
    column :store_types do |code|
      (code.store_types.join(',').to_s).truncate(30)
    end
    column :retailer_groups
    column :start_date
    column :end_date
    column :is_active
    column 'Home_Tier_1' do |c|
      tier = c.locations.to_a.each
      tier.include? Screen.screen_locations[:home_tier_1]
    end
    column 'Home_Tier_2' do |c|
      tier = c.locations.to_a.each
      tier.include? Screen.screen_locations[:home_tier_2]
    end
    column 'Store_Tier_1' do |c|
      tier = c.locations.to_a.each
      tier.include? Screen.screen_locations[:store_tier_1]
    end
    column 'Store_Tier_2' do |c|
      tier = c.locations.to_a.each
      tier.include? Screen.screen_locations[:store_tier_2]
    end
    actions
  end

  show do
    attributes_table :name, :priority, :group, :is_active, :start_date, :end_date do
      row :retailer_ids do |code|
        code.retailer_ids.join(', ')
      end
      row :product_ids do |code|
        code.product_ids.join(', ')
      end
      row :store_types do |code|
        (code.store_types.join(', '))
      end
      row :retailer_groups do |code|
        (code.retailer_groups.join(','))
      end
      row 'Home_Tier_1' do |c|
        tier = c.locations.to_a.each
        status_tag tier.include? Screen.screen_locations[:home_tier_1]
      end
      row 'Home_Tier_2' do |c|
        tier = c.locations.to_a.each
        status_tag tier.include? Screen.screen_locations[:home_tier_2]
      end
      row 'Store_Tier_1' do |c|
        tier = c.locations.to_a.each
        status_tag tier.include? Screen.screen_locations[:store_tier_1]
      end
      row 'Store_Tier_2' do |c|
        tier = c.locations.to_a.each
        status_tag tier.include? Screen.screen_locations[:store_tier_2]
      end
      row :photo do |p|
        image_tag(p.photo.url(:medium), :height => '50')
      end
      row :photo_ar do |p|
        image_tag(p.photo_ar.url(:medium), :height => '50')
      end
      row :banner_photo do |p|
        image_tag(p.banner_photo.url(:medium), :height => '50')
      end
      row :banner_photo_ar do |p|
        image_tag(p.banner_photo_ar.url(:medium), :height => '50')
      end
      # row :retailers do
      #   screen.retailers.pluck(:company_name)*(', ')
      # end
      # panel "Products" do
      #   table_for screen.screen_products.includes(:product) do
      #     column :product
      #     column :priority
      #   end
      # end
    end
  end

  filter :id
  filter :name
  filter :priority
  filter :group
  filter :is_active
  filter :start_date
  filter :end_date

  filter :by_home_tier_1_in, label: "Home Tier 1", as: :boolean, collection: { "true": 1, "false": 0 }
  filter :by_home_tier_2_in, label: "Home Tier 2", as: :boolean, collection: { "true": 1, "false": 0 }
  filter :by_store_tier_1_in, label: "Store Tier 1", as: :boolean, collection: { "true": 1, "false": 0 }
  filter :by_store_tier_2_in, label: "Store Tier 2", as: :boolean, collection: { "true": 1, "false": 0 }
  filter :created_at
  filter :updated_at

  controller do
    def create
      if params[:screen][:start_date].blank? and params[:screen][:end_date].blank?
        super
        return
      end
      parameter = {
        name: params[:screen][:name],
        priority: params[:screen][:priority],
        group: params[:screen][:group],
        is_active: params[:screen][:is_active],
      }
      @screen = Screen.new(parameter)
      @screen.photo = params[:screen][:photo]
      @screen.photo_ar = params[:screen][:photo_ar]
      @screen.banner_photo = params[:screen][:banner_photo]
      @screen.banner_photo_ar = params[:screen][:banner_photo_ar]
      @screen.start_date = params[:screen][:start_date].to_time + 4.hours
      @screen.end_date = params[:screen][:end_date].to_time + 4.hours
      @screen.locations = "{#{params[:screen][:locations].reject(&:blank?).map(&:to_i).join(',')}}"
      @screen.store_types = "{#{params[:screen][:store_types_ids].split(',').map(&:to_i).join(',')}}"
      @screen.retailer_groups = "{#{params[:screen][:retailer_groups].split(',').map(&:to_i).join(',')}}"
      if params[:screen][:select_all_retailers].to_i == 1
        @screen.screen.retailer_ids = Retailer.where(is_active: true).pluck(:id)
      else
        @screen.retailer_ids = "{#{params[:screen][:retailer_ids].split(',').map(&:to_i).join(',')}}"
      end
      if @screen.valid?
        @screen.save
        Screen.transaction do
        #   create_screen_retailers(@screen.id)
          create_screen_products(@screen.id)
        end
        redirect_to admin_screen_path(id: @screen.id), flash: { notice: "Screen has been created!" }
      else
        super
      end
    end

    def update
      if params[:screen][:start_date].blank? and params[:screen][:end_date].blank?
        super
        return
      end
      screen = Screen.find_by(id: params[:id])
      screen[:name] = params[:screen][:name]
      screen[:priority] = params[:screen][:priority]
      screen[:group] = params[:screen][:group]
      screen[:is_active] = params[:screen][:is_active]
      screen.photo = params[:screen][:photo] if params[:screen][:photo].present?
      screen.photo_ar = params[:screen][:photo_ar] if params[:screen][:photo_ar].present?
      screen.banner_photo = params[:screen][:banner_photo] if params[:screen][:banner_photo].present?
      screen.banner_photo_ar = params[:screen][:banner_photo_ar] if params[:screen][:banner_photo_ar].present?
      screen.start_date = params[:screen][:start_date].to_time + 4.hours
      screen.end_date = params[:screen][:end_date].to_time + 4.hours
      screen.locations = "{#{params[:screen][:locations].reject(&:blank?).map(&:to_i).join(',')}}"
      screen.store_types = "{#{params[:screen][:store_types_ids].split(',').map(&:to_i).join(',')}}"
      screen.retailer_groups = "{#{params[:screen][:retailer_groups].split(',').map(&:to_i).join(',')}}"
      if params[:screen][:select_all_retailers].to_i == 1
        screen.retailer_ids = Retailer.where(is_active: true).pluck(:id)
      else
        screen.retailer_ids = "{#{params[:screen][:retailer_ids].split(',').map(&:to_i).join(',')}}"
      end
      if screen.save
        Screen.transaction do
          clear_old_record(screen)
          create_screen_products(screen.id)
        #   create_screen_retailers(screen.id)
        end
        redirect_to admin_screen_path(id: screen.id), flash: { notice: "Screen has been successfully updated!" }
      else
        super
      end
    end

    # def create_screen_retailers(screen_id)
    #   retailers = if params[:screen][:select_all_retailers].to_i == 1
    #                 Retailer.where(is_active: true).pluck(:id)
    #               else
    #                 params[:screen][:screen_retailer_ids].split(',')
    #               end
    #   # retailers = retailers | Retailer.where(retailer_group_id: params[:screen][:retailer_groups].split(',')).pluck(:id)
    #   unless retailers.blank?
    #     values = retailers.map { |u| "(#{screen_id},#{u})" }.join(",")
    #     ActiveRecord::Base.connection.execute("INSERT INTO screen_retailers (screen_id, retailer_id) VALUES #{values}")
    #   end
    # end

    def create_screen_products(screen_id)
      if params[:screen][:screen_product_ids].present?
        i = 0
        products = params[:screen][:screen_product_ids]
        values = products.split(',').map { |u| "(#{screen_id},#{u},#{i += 1})" }.join(",")
        ActiveRecord::Base.connection.execute("INSERT INTO screen_products (screen_id, product_id, priority) VALUES #{values}")
      end
      # if params[:screen][:screen_products_attributes].present?
      # values = params[:screen][:screen_products_attributes].map{|u| "(#{screen_id},#{u[1][:product_id]},#{u[1][:priority]})"}.join(",")
      # ActiveRecord::Base.connection.execute("INSERT INTO screen_products (screen_id, product_id, priority) VALUES #{values}")
      # end
    end

    def clear_old_record(screen)
      # retailers = params[:screen][:retailer_ids].reject(&:blank?)
      # ScreenRetailer.where(screen_id: screen.id).delete_all # unless retailers.blank?
      # if params[:screen][:screen_products_attributes].present?
      ScreenProduct.where(screen_id: screen.id).delete_all
      # params[:screen][:screen_products_attributes] = params[:screen][:screen_products_attributes].select{ |k,v| v[:_destroy].to_i == 0 }
      # end
    end

    def loca
      @loca ||= Screen.screen_locations
    end
  end
end