# frozen_string_literal: true

ActiveAdmin.register Brand do
  menu parent: "Collections"
  permit_params :name, :name_ar, :priority, :photo, :brand_logo_1, :brand_logo_2, :slug, :group_name, :seo_data

  index do
    column :name
    column :name_ar
    column :products do |brand|
      brand.products.count
    end
    column :priority
    column :slug
    column :group_name
    column :created_at
    actions
  end

  filter :name
  filter :priority

  show do |brand|
    attributes_table :name, :name_ar, :priority, :slug, :group_name, :seo_data, :created_at do
      row :photo do
        image_tag(brand.photo_url, :height => '100') if brand.photo
      end
      row :brand_logo_1 do
        image_tag(brand.logo1_url, :height => '100') if brand.brand_logo_1
      end
      row :brand_logo_2 do
        image_tag(brand.logo2_url, :height => '100') if brand.brand_logo_2
      end
    end

  end

  form html: {enctype: "multipart/form-data"} do |f|
    f.inputs "Basic details" do
      f.input :name
      f.input :name_ar
      f.input :priority, hint: 'boost/increment rank'
      f.input :slug
      f.input :group_name
      f.input :seo_data
      f.input :photo, as: :file
      f.input :brand_logo_1, as: :file
      f.input :brand_logo_2, as: :file
    end
    f.actions
  end

  action_item :view_site do
    link_to "Brands Priority", admin_brand_priority_path
  end

  controller do
    def destroy
      brand = Brand.includes(:products).find(params[:id])
      have_products = brand.products.count
      if have_products == 0
        brand.destroy
        redirect_to admin_brands_path
      else
        redirect_to admin_brands_path, flash: {notice: "Removal impossible. There is a product within this brand."}
      end
    end

    # def update
    #   brand = Brand.find(params[:id])
    #   if !params[:brand][:name].blank?
    #     update_params = {}
    #     update_params[:name] = params[:brand][:name]
    #     update_params[:priority] = params[:brand][:priority]
    #     update_params[:photo] = params[:brand][:photo] unless params[:brand][:photo].blank?
    #     update_params[:brand_logo_1] = params[:brand][:brand_logo_1] unless params[:brand][:brand_logo_1].blank?
    #     update_params[:brand_logo_2] = params[:brand][:brand_logo_2] unless params[:brand][:brand_logo_2].blank?
    #     brand.update(update_params)
    #     redirect_to admin_brands_path
    #   else
    #     redirect_to admin_brands_path, flash: { notice: "You cannot set a blank name!" }
    #   end
    # end

    # def create
    #   if !params[:brand][:name].blank?
    #     Brand.create({name: params[:brand][:name], photo: params[:brand][:photo], brand_logo_1: params[:brand][:brand_logo_1], brand_logo_2: params[:brand][:brand_logo_2]})
    #     redirect_to admin_brands_path
    #   else
    #     redirect_to admin_brands_path, flash: { notice: "You cannot set a blank name!" }
    #   end
    # end

  end

end
