# frozen_string_literal: true

ActiveAdmin.register Category do
  menu parent: 'Collections'
  config.sort_order = 'created_at_desc'

  scope :with_photo
  scope :without_photo
  scope :parent_categories

  permit_params :name, :name_ar, :description, :description_ar, :parent_id, :photo, :logo, :logo1, :is_show_brand, :is_food,
                :priority, :slug, :message, :message_ar, :seo_data, :current_tags, :pickup_priority, retailer_ids: []
  controller do
    def scoped_collection
      super.includes :parent
    end
  end

  index do
    # sortable_tree_columns
    column :photo do |cat|
      image_tag(cat.photo.url(:icon))
    end
    column :name
    column :name_ar
    column :products do |cat|
      cat.products.count
    end
    column :parent
    column 'Is_Show_Brand' do |c|
      brand = c.current_tags.to_a.each
      status_tag brand.include? Category.tags[:is_show_brand]
    end
    column 'Is_Food' do |c|
      brand = c.current_tags.to_a.each
      status_tag brand.include? Category.tags[:is_food]
    end
    column 'Pg-18' do |c|
      brand = c.current_tags.to_a.each
      status_tag brand.include? Category.tags[:pg_18]
    end
    column :priority
    column :pickup_priority
    # column :is_show_brand
    # column :is_food
    column :slug
    column :created_at
    actions
  end

  csv do
    column :id
    column :name
    column :products do |cat|
      cat.products.count
    end
    column 'Product Id' do |cat|
      cat.parent.id unless cat.parent.nil?
    end
    column :parent do |cat|
      cat.parent.name unless cat.parent.nil?
    end
    column :priority
    column :pickup_priority
    column 'Is_Show_Brand' do |c|
      brand = c.current_tags.to_a.each
      brand.include? Category.tags[:is_show_brand]
    end
    column 'Is_Food' do |c|
      brand = c.current_tags.to_a.each
      brand.include? Category.tags[:is_food]
    end
    column 'Pg-18' do |c|
      brand = c.current_tags.to_a.each
      brand.include? Category.tags[:pg_18]
    end
    # column :is_show_brand
    column :created_at
  end

  filter :name
  filter :parent_id
  filter :by_is_show_brand_in, label: 'Is Show Brand', as: :boolean, collection: { 'true' => 1, 'false' => 0 }
  filter :by_is_food_in, label: 'Is Food', as: :boolean, collection: { 'true' => 1, 'false' => 0 }
  filter :by_pg_18_in, label: 'PG-18', as: :boolean, collection: { 'true' => 1, 'false' => 0 }
  # filter :is_show_brand
  # filter :is_food

  show do |category|
    attributes_table :name, :name_ar, :description, :description_ar, :parent, :priority, :pickup_priority, :created_at, :slug, :message, :message_ar, :seo_data do
      # :is_show_brand, :is_food,
      row 'Is_Show_Brand' do |c|
        brand = c.current_tags.to_a.each
        status_tag brand.include? Category.tags[:is_show_brand]
      end
      row 'Is_Food' do |c|
        brand = c.current_tags.to_a.each
        status_tag brand.include? Category.tags[:is_food]
      end
      row 'Pg_18' do |c|
        brand = c.current_tags.to_a.each
        status_tag brand.include? Category.tags[:pg_18]
      end
      row :photo do
        image_tag(category.photo_url, height: '100') if category.photo
      end
      row :colored_img do
        image_tag(category.colored_img_url, height: '100') if category.logo
      end
      # row :logo1 do
      #   image_tag(category.logo1_url, height: '100') if category.logo1
      # end
      row :retailers do
        category.retailers.pluck(:company_name) * (', ')
      end
    end
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Basic details' do
      f.input :name
      f.input :name_ar
      f.input :description
      f.input :description_ar
      f.input :parent, as: :select, collection: Category.order(:name).all.map { |c| [c.name_and_id, c.id] }
      f.input :priority
      f.input :pickup_priority
      f.input :current_tags, as: :check_boxes, collection: controller.tagis
      f.input :slug
      f.input :message
      f.input :message_ar
      f.input :seo_data
      f.input :photo, as: :file
      f.input :logo, as: :file, label: 'Colored Img'
      # f.input :logo1, as: :file
      f.input :retailers, as: :select, multiple: true, collection: Retailer.order(:company_name).all.map { |c| [c.company_name, c.id] }
      f.input :select_all_retailers, as: :boolean, label: 'Select All Retailers', input_html: { onclick: "$('#category_retailer_ids option').prop('selected', $('#select_all_retailers')[0].checked);", id: 'select_all_retailers' }
    end
    f.actions
  end

  controller do
    def destroy
      category = Category.find(params[:id])
      have_products = ProductCategory.exists?({ category_id: params[:id] })
      if not have_products
        category.destroy
        redirect_to admin_categories_path
      else
        redirect_to admin_categories_path, flash: { notice: 'Removal impossible. There is a product having this category.' }
      end
    end

    def create
      cat_tags = params[:category][:current_tags].reject(&:blank?)
      unless cat_tags.blank?
        cat_tags = cat_tags.map(&:to_i)
        params[:category][:is_food] = cat_tags.include? 2
        params[:category][:is_show_brand] = cat_tags.include? 1
        params[:category][:current_tags] = "{#{cat_tags.join(',')}}"
      end

      super
    end

    def update
      if params[:category][:current_tags].reject(&:blank?).blank?
        params[:category][:is_food] = false
        params[:category][:is_show_brand] = false
        params[:category][:current_tags] = '{}'
      else
        cat_tags = params[:category][:current_tags].reject(&:blank?).map(&:to_i)
        params[:category][:is_food] = cat_tags.include? 2
        params[:category][:is_show_brand] = cat_tags.include? 1
        params[:category][:current_tags] = "{#{cat_tags.join(',')}}"
      end
      super
    end

    def tagis
      @tagis ||= Category.tags
    end

    # def update
    #   category = Category.find(params[:id])
    #   if !params[:category][:name].blank?
    #     update_params = {}
    #     update_params[:name] = params[:category][:name]
    #     update_params[:parent_id] = params[:category][:parent_id]
    #     update_params[:is_show_brand] = params[:category][:is_show_brand]
    #     update_params[:photo] = params[:category][:photo] if params[:category][:photo]
    #     update_params[:logo] = params[:category][:logo] if params[:category][:logo]

    #     category.update(update_params)
    #     redirect_to admin_categories_path
    #   else
    #     redirect_to admin_categories_path, flash: { notice: "You cannot set a blank name!" }
    #   end
    # end

    # def create
    #   if !params[:category][:name].blank?
    #     Category.create({name: params[:category][:name], parent_id: params[:category][:parent_id], photo: params[:category][:photo], logo: params[:category][:logo], is_show_brand: params[:category][:is_show_brand]})
    #     redirect_to admin_categories_path
    #   else
    #     redirect_to admin_categories_path, flash: { notice: "You cannot set a blank name!" }
    #   end
    # end

  end
end