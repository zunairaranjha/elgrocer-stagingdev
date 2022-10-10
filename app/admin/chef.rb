# frozen_string_literal: true

ActiveAdmin.register Chef do
  menu parent: "Recipe"

  permit_params :name, :insta, :blog, :photo, :slug, :description, :seo_data, :priority, :translations => {}

  remove_filter :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at, :slugs, :recipes

  form html: {enctype: "multipart/form-data"} do |f|
    f.inputs "Basic details" do
      f.input :name_en
      f.input :name_ar
      f.input :insta
      # f.input :blog
      f.input :slug
      # f.input :description
      f.input :seo_data
      f.input :priority
      f.input :description_en
      f.input :description_ar
      f.input :photo, as: :file
    end
    f.actions
  end

  index do
    column :photo do |obj|
      image_tag(obj.photo.url(:icon))
    end
    column :name_en
    column :name_ar
    column :insta
    column :deep_link do |obj|
      obj.blog
    end
    column :slug
    # column :description
    column :storyly_slug
    column :priority
    column :description_en
    column :description_ar
    column :created_at
    column :updated_at
    actions
  end


  show do |obj|
    attributes_table :name_en, :name_ar, :insta, :slug, :description, :seo_data, :priority, :storyly_slug, :description_en, :description_ar  do
      row :deep_link do
        obj.blog
      end
      row :photo do
        image_tag(obj.photo_url, :height => '100') if obj.photo
      end
      row :created_at
      row :updated_at
    end
  end

  controller do
    def create
      set_params
      super
      @chef.update(storyly_slug: "chef_#{@chef.id}", blog: Firebase::LinkShortener.new.chef_deep_link(@chef.id))
      @chef
    end
    
    def update
      set_params
      super
    end

    def set_params
      params[:chef][:translations] = {}
      params[:chef][:translations][:name_en] = params[:chef][:name_en]
      params[:chef][:translations][:name_ar] = params[:chef][:name_ar]
      params[:chef][:translations][:description_en] = params[:chef][:description_en]
      params[:chef][:translations][:description_ar] = params[:chef][:description_ar]
    end

    def destroy
      chef = Chef.find(params[:id])
      have_recipes = chef.recipes
      if not have_recipes.any?
        chef.destroy
        redirect_to admin_chefs_path
      else
        redirect_to admin_chefs_path, flash: {notice: "Removal impossible. This chef is having recipe."}
      end
    end
  end
end
