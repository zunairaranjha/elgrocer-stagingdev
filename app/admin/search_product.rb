# frozen_string_literal: true

ActiveAdmin.register Product, as: "search_product" do
  menu false
  # menu brand: 'Collections'
  # menu categories: 'Collections'
  # menu parent: "Products"

  # scope :all
  # scope :with_photo
  # scope :without_photo
  # scope :without_brand
  # scope :promotional

  permit_params :barcode, :size_unit, :shelf_life, :commission_value, :brand_id, :name, :description, :search_keywords, :name_ar, :description_ar, :size_unit_ar, :photo, :slug, :category_parent_id

  # controller do
  #   def scoped_collection
  #     Product.unscoped{
  #       super.includes :categories, :subcategories, :brand, :category_parent
  #     }
  #   end
  # end


  controller do
    def scoped_collection
      Product.select("products.*, CONCAT(products.id, ' : ', products.name, ' : ', products.size_unit) as full_name")
    end
  end

  index do
    # column :photo do |obj|
    #   image_tag(obj.photo.url(:icon))
    # end
    column "Name", :full_name
    # column :name_ar
    column :barcode
    # column :image_exists do |item|
    #   !item.photo_file_size.nil?
    # end
    column :size_unit
    # column :shelf_life
    # column :slug
    # column :is_promotional
    # column :created_at
    # column :category_parent
    # column :category do |item|
    #   if !item.categories.first.nil?
    #     item.categories.first.name
    #   end
    # end
    # column :subcategory do |item|
    #   if !item.subcategories.first.nil?
    #     item.subcategories.first.name
    #   end
    # end
    # column :brand
    # actions
  end

  filter :barcode_includes, as: :string
  filter :name
  # filter :brand_name_cont, as: :string
  # filter :subcategories_name_cont, as: :string
  # filter :categories_name_cont, as: :string

end
