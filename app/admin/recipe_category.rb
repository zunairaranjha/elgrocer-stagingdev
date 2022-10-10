# frozen_string_literal: true

ActiveAdmin.register RecipeCategory do
  menu parent: "Recipe"

  permit_params :name, :photo, :description, :slug, :seo_data, :translations => {} #,:parent_id

  filter :name #,:parent_id

  form html: {enctype: "multipart/form-data"} do |f|
    f.inputs "Basic details" do
      f.input :name_en
      f.input :name_ar
      f.input :slug
      # f.input :description
      f.input :seo_data
      # f.input :parent
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
    column :slug
    # column :description
    # column :parent_id
    column :created_at
    column :updated_at
    actions
  end

  show do |obj|
    attributes_table :name_en,:name_ar, :slug, :seo_data do
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
    end
    
    def update
      set_params
      super
    end

    def set_params
      params[:recipe_category][:translations] = {}
      params[:recipe_category][:translations][:name_en] = params[:recipe_category][:name_en]
      params[:recipe_category][:translations][:name_ar] = params[:recipe_category][:name_ar]
    end

    def destroy
      recipe_category = RecipeCategory.find(params[:id])
      have_recipes = recipe_category.recipes
      if not have_recipes.any?
        recipe_category.destroy
        redirect_to admin_recipe_categories_path
      else
        redirect_to admin_recipe_categories_path, flash: {notice: "Removal impossible. This chef is having recipe."}
      end
    end
  end
end
