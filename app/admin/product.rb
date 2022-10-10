# frozen_string_literal: true

ActiveAdmin.register Product do
  menu brand: 'Collections'
  menu categories: 'Collections'
  menu parent: "Products"
  includes :categories, :subcategories, :brand, :category_parent

  scope :all
  scope :with_photo
  scope :without_photo
  scope :without_brand
  # scope :promotional

  permit_params :barcode, :size_unit, :shelf_life, :commission_value, :brand_id, :name, :description, :search_keywords, :name_ar, :description_ar, :size_unit_ar, :photo, :slug, :category_parent_id, subcategory_ids: []

  controller do
    def scoped_collection
      Product.unscoped.distinct
    end
  end

  csv do
    column :id
    column :barcode
    column :brand do |item|
      unless item.brand.nil?
        item.brand.name
      end
    end
    column :created_at
    column :updated_at
    column :name
    column :description
    column :image_exists do |item|
      !item.photo_file_size.nil?
    end
    column :photo_file_name
    column :photo_content_type
    column :photo_file_size
    column :photo_updated_at
    # column :shelf_life
    column :size_unit
    # column :is_local
    # column :country_alpha2
    # column "Promotion Only" do |obj|
    #   obj.is_promotional
    # end
    # column :is_promotional
    column :category do |item|
      item.categories.map { |c| c.name }.uniq.join(", ")
    end
    column :subcategory do |item|
      item.subcategories.map { |sc| sc.name }.uniq.join(", ")
    end
  end

  index do
    column :photo do |obj|
      image_tag(obj.photo.url(:icon))
    end
    column :name
    column :name_ar
    column :barcode
    column :image_exists do |item|
      !item.photo_file_size.nil?
    end
    column :size_unit
    # column :shelf_life
    column :slug
    # column "Promotion Only" do |obj|
    #   obj.is_promotional
    # end
    column :created_at
    column :category_parent
    column :category do |item|
      item.categories.map { |c| c.name }.uniq.join(", ")
    end
    column :subcategory do |item|
      item.subcategories.map { |sc| sc.name }.uniq.join(", ")
    end
    column :brand
    actions
  end

  # filter :barcode
  filter :barcode_includes, as: :string
  filter :name
  # filter :is_promotional, label: "Promotion Only"
  filter :brand_name_cont, as: :string
  filter :subcategories_name_cont, as: :string
  filter :categories_name_cont, as: :string
  # filter :brand
  # filter :subcategories, as: :select, collection: Proc.new { Category.where(parent_id: nil).all.map { |c| [c.name, c.subcategories.map { |s| [s.name, s.id] }]} }
  # filter :categories, as: :select, collection: Proc.new { Category.where(parent_id: nil).all.map { |c| [c.name, c.id]} }
  filter :has_photo
  filter :created_at
  filter :updated_at

  show do |product|
    attributes_table :name, :name_ar, :size_unit, :size_unit_ar, :search_keywords, :barcode, :description, :description_ar, :shelf_life, :slug, :created_at do
      # row :promotion_only do
      #   product.is_promotional
      # end
      row :photo do
        image_tag(product.photo_url, :height => '100') if product.photo
      end
      row :brand do
        product.brand.name if product.brand
      end
      row :category_parent
      row('categories') do
        product.subcategories.map { |sc| sc.name }.join(", ")
      end
      row :shop_promotions do
        link_to "see all", admin_shop_promotions_path(q: {product_id_eq: product.id})
      end
      row :shop_promotions do
        link_to "Add a promotion", new_admin_shop_promotion_path("shop_promotion[product_id]" => product.id)
      end
    end

    panel I18n.t(:product_in_shop, :scope => ["activerecord", "labels", "product"]) do
      table_for Shop.unscoped.includes(:retailer).where(product_id: product) do
        column("ID") { |c| link_to(c.id, admin_shop_path(c.id)) }
        column('Retailer name') { |c| link_to(c.retailer.company_name, admin_retailer_path(c.retailer_id)) }
        column('Price') { |c| (c.price_dollars.to_f + c.price_cents.to_f/100) }
        column :is_published
        column :is_available
      end
    end
  end

  form html: { enctype: "multipart/form-data" } do |f|
    f.inputs "Basic details" do
      f.input :name
      f.input :name_ar
      f.input :barcode
      f.input :description
      f.input :description_ar
      f.input :brand, as: :select, collection: Brand.order(:name).all.map { |b| [ b.name_and_id, b.id ] }
      f.input :size_unit
      f.input :size_unit_ar
      f.input :search_keywords
      f.input :shelf_life
      f.input :slug
      # f.input :is_promotional, label: "Promotion Only", hint: "If this is true no Shop will be entertained only active promotions will be accounted"
      # f.input :category_parent, as: :select, collection: Category.where(parent_id: nil).all.map { |c| [c.name_and_id, c.id]}
      # f.input :subcategories, as: :select, collection: Category.where(parent_id: nil).all.map { |c| [c.name_and_id, c.subcategories.map { |s| [s.name_and_id, s.id] }]}
      f.input :category_parent, as: :select, collection: controller.category_suggest.map { |c| [c.name_and_id, c.id]}
      f.input :subcategories, as: :select, collection: controller.category_suggest.map { |c| [c.name_and_id, c.subcategories.map { |s| [s.name_and_id, s.id] }]}
      f.input :photo, as: :file
    end
    f.actions
  end


  controller do
    def destroy
      product = Product.unscoped.find(params[:id])
      have_shops = Shop.unscoped.exists?({product_id: params[:id]})
      if not have_shops
        product.destroy
        redirect_to admin_products_path
      else
        redirect_to admin_product_path, flash: { notice: "Removal impossible. There is a retailer having this product." }
      end
    end
    def category_suggest
      @category_suggest ||= Category.includes(:subcategories).where(parent_id: nil).order(:name , :id)
    end
  end
end
