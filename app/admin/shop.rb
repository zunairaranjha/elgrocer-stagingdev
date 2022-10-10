# frozen_string_literal: true

ActiveAdmin.register Shop do
  menu parent: 'Products', label: 'Products in shops'

  actions :all # , :except => [:new]
  includes :categories, :product_categories, :subcategories, :brand, :product, :retailer
  permit_params :price_cents, :price_dollars, :commission_value, :price_currency, :product_rank, :is_published, :is_available, :is_promotional, :product_id,
                :promotion_only, :retailer_id, :available_for_sale, detail: {},
                shop_promotions_attributes: %i[id retailer_id product_id start_time end_time price product_limit time_of_start time_of_end]
  config.per_page = [50, 100, 500]
  # scope :all
  # scope :published
  # scope :unpublished
  # scope :available
  # scope :unavailable
  # scope :particular_commission_value
  # scope :promotional

  controller do
    def scoped_collection
      Shop.unscoped.distinct
    end
  end

  filter :retailer_id_equals, label: 'retailer_id'
  filter :retailer_company_name_cont, as: :string
  filter :product_id, label: 'product_id'
  filter :product_barcode_includes, as: :string
  filter :product_name_cont, as: :string
  filter :brand_id_equals, label: 'brand_id'
  filter :brand_name_cont, as: :string, label: I18n.t(:brand_name, scope: %w[activerecord labels product])
  filter :subcategories_id_equals, label: 'subcategories_id'
  filter :subcategories_name_cont, as: :string, label: I18n.t(:subcategory_name, scope: %w[activerecord labels product])
  filter :categories_id_equals, label: 'categories_id'
  filter :categories_name_cont, as: :string, label: I18n.t(:category_name, scope: %w[activerecord labels product])
  # filter :subcategories, as: :select, collection: Proc.new { Category.where(parent_id: nil).all.map { |c| [c.name, c.subcategories.map { |s| [s.name, s.id] }]} }
  # filter :categories, as: :select, collection: Proc.new { Category.where(parent_id: nil).all.map { |c| [c.name, c.id]} }
  filter :is_published
  filter :is_available
  # filter :product_is_promotional, as: :select, lable: 'is_promotional'
  filter :is_promotional
  filter :promotion_only
  filter :created_at
  filter :updated_at
  # filter(:categories, { as: :select, multiple: true, input_html: { class: :select2, style: "width: 100%;" }, label: I18n.t(:categories) })

  batch_action :publish do |ids|
    # batch_action_collection.find(ids).each do |shop|
    #   shop.is_published = true
    #   shop.owner_for_log = current_admin_user
    #   begin
    #     shop.save
    #   rescue Exception => e

    #   end
    # end
    # Shop.unscoped.where(id: ids).update_all(is_published: true, updated_at: Time.now)

    detail = { owner_type: current_admin_user.class.name, owner_id: current_admin_user.id }
    shops = Shop.unscoped.where(id: ids).not_oos
    shops.update_all("is_published = true, updated_at= '#{Time.now}', detail = detail::jsonb || '#{detail.to_json}'::jsonb")
    shops = Shop.where(id: ids, is_available: true)
    Product.products_to_algolia(product_ids: shops.pluck(:product_id)) unless shops.blank?
    redirect_to admin_shops_path, alert: 'The products have been published.'
  end

  batch_action :Unpublish do |ids|
    # batch_action_collection.find(ids).each do |shop|
    #   shop.is_published = false
    #   shop.owner_for_log = current_admin_user
    #   begin
    #     shop.save
    #   rescue Exception => e

    #   end
    # end
    detail = { owner_type: current_admin_user.class.name, owner_id: current_admin_user.id }
    Shop.unscoped.where(id: ids).update_all("is_published = false, updated_at= '#{Time.now}', detail = detail::jsonb || '#{detail.to_json}'::jsonb")
    # Shop.unscoped.where(id: ids).update_all(is_published: false, updated_at: Time.now)
    Product.products_to_algolia(product_ids: Shop.unscoped.where(id: ids).pluck(:product_id))
    redirect_to admin_shops_path, alert: 'The products have been Unpublished.'
  end

  batch_action :available do |ids|
    # batch_action_collection.find(ids).each do |shop|
    #   shop.is_available = true
    #   shop.owner_for_log = current_admin_user
    #   begin
    #     shop.save
    #   rescue Exception => e

    #   end
    # end
    detail = { owner_type: current_admin_user.class.name, owner_id: current_admin_user.id }
    shops = Shop.unscoped.where(id: ids).not_oos
    shops.update_all("is_available = true, updated_at= '#{Time.now}', detail = detail::jsonb || '#{detail.to_json}'::jsonb")
    # Shop.unscoped.where(id: ids).update_all(is_available: true, updated_at: Time.now)
    shops = Shop.where(id: ids, is_published: true)
    Product.products_to_algolia(product_ids: shops.pluck(:product_id)) unless shops.blank?
    redirect_to admin_shops_path, alert: 'The products have been available.'
  end

  batch_action :unavailable do |ids|
    # batch_action_collection.find(ids).each do |shop|
    #   shop.is_available = false
    #   shop.owner_for_log = current_admin_user
    #   begin
    #     shop.save
    #   rescue Exception => e

    #   end
    # end

    detail = { owner_type: current_admin_user.class.name, owner_id: current_admin_user.id  }
    Shop.unscoped.where(id: ids).update_all("is_available = false, updated_at= '#{Time.now}', detail = detail::jsonb || '#{detail.to_json}'::jsonb")

    # Shop.unscoped.where(id: ids).update_all(is_available: false, updated_at: Time.now)
    Product.products_to_algolia(product_ids: Shop.unscoped.where(id: ids).pluck(:product_id))
    redirect_to admin_shops_path, alert: 'The products have been unavailable.'
  end

  batch_action :active_promotion_for do |ids|
    Shop.unscoped.where(id: ids).update_all(is_promotional: true, updated_at: Time.now)
    shops = Shop.where(id: ids, is_available: true, is_published: true)
    Product.products_to_algolia(product_ids: shops.pluck(:product_id)) unless shops.blank?
    redirect_to admin_shops_path, alert: 'Promotion is active for products.'
  end

  batch_action :deactive_promotion_for do |ids|
    Shop.unscoped.where(id: ids).update_all(is_promotional: false, updated_at: Time.now)
    shops = Shop.where(id: ids, is_available: true, is_published: true)
    Product.products_to_algolia(product_ids: shops.pluck(:product_id)) unless shops.blank?
    redirect_to admin_shops_path, alert: 'Promotion is deactive for products.'
  end

  index title: I18n.t('products_in_shops', scope: 'activerecord.labels.shop') do
    selectable_column
    column :photo do |obj|
      if obj.product
        obj.product.photo ? image_tag(obj.product.photo.url(:icon)) : nil
      else
        image_tag(Product.unscoped.find_by(id: obj.product_id).photo.url(:icon)) rescue image_tag('/images/icon/missing.png')
      end
    end
    column :product_name do |obj|
      if obj.product
        link_to(obj.product.name, admin_product_path(obj.product_id)) rescue 'Not found'
      else
        link_to(Product.unscoped.find_by(id: obj.product_id).name, admin_product_path(obj.product_id)) rescue 'Not found'
      end
    end
    column :retailer_name do |obj|
      if obj.retailer
        link_to(obj.retailer.company_name, admin_retailer_path(obj.retailer_id)) rescue 'Not found'
      else
        'Not found'
      end
    end
    column :price do |obj|
      number_with_precision((obj.price_dollars.to_f + obj.price_cents.to_f / 100), precision: 2)
    end
    # column(I18n.t('commission_value_exception', scope: 'activerecord.labels.commissions')) { |c| c.commission_value}
    column :barcode do |obj|
      if obj.product
        obj.product.barcode rescue 'Not found'
      else
        Product.unscoped.find_by(id: obj.product_id).barcode rescue 'Not found'
      end

    end
    column :image_exists do |item|
      if item.product
        item.product.photo.url != '/images/original/missing.png'
      else
        'Not found'
      end
    end
    column :size_unit do |obj|
      if obj.product
        obj.product.size_unit rescue 'Not found'
      else
        Product.unscoped.find_by(id: obj.product_id).size_unit rescue 'Not found'
      end
    end
    # column :shelf_life do |obj|
    #   if obj.product
    #     obj.product.shelf_life rescue 'Not found'
    #   else
    #     Product.unscoped.find_by(id: obj.product_id).shelf_life rescue 'Not found'
    #   end
    # end
    column :created_at
    column :updated_at
    column :category do |item|
      if item.product
        item.categories.map(&:name).uniq.join(', ') rescue nil
      else
        Product.unscoped.find_by(id: item.product_id).categories.map(&:name).uniq.join(', ') rescue nil
      end
    end
    column :subcategory do |item|
      if item.product
        item.subcategories.map(&:name).uniq.join(', ') rescue nil
      else
        Product.unscoped.find_by(id: item.product_id).subcategories.map(&:name).uniq.join(', ') rescue nil
      end
    end
    column :brand do |obj|
      if obj.product
        obj.product.brand.name rescue nil
      else
        Product.unscoped.find_by(id: obj.product_id).brand.name rescue nil
      end
    end
    column 'Rank', :product_rank
    column 'Published', :is_published
    column 'Available', :is_available
    column :is_promotional
    column :promotion_only
    column 'Permanently Disabled' do |obj|
      obj.detail['permanently_disabled'].to_i.positive?
    end
    column 'Available Qty', :available_for_sale
    # column 'Promotional' do |obj|
    #     obj.product.is_promotional
    # end
    column :detail do |shop|
      "#{shop.detail['owner_type']}-#{shop.detail['owner_id']}"
    end
    actions
  end

  show do |shop|
    product = shop.product || Product.unscoped.find_by(id: shop.product_id)
    panel I18n.t(:basic_data, scope: %w[activerecord labels shop]) do
      attributes_table_for shop do
        row :product_name do
          product.name rescue 'Not found'
        end
        row :retailer_name do |obj|
          obj.retailer.company_name rescue 'Not found'
        end
        row :photo do
          image_tag(product.photo_url, height: '100') if product
        end
        row :brand do
          product.brand.name if product.brand rescue 'Not found'
        end
        row ('categories') do
          product.subcategories.map(&:name).join(', ') rescue 'Not found'
        end
        row :product_rank
        row :is_published
        row :is_available
        row :is_promotional
        row :promotion_only
        row :available_qty, &:available_for_sale
        row :detail do |shop|
          "#{shop.detail['owner_type']}-#{shop.detail['owner_id']}"
        end
      end
    end
    panel I18n.t(:price_data, scope: %w[activerecord labels shop]) do
      attributes_table_for shop do
        row :price do |obj|
          number_with_precision((obj.price_dollars.to_f + obj.price_cents.to_f / 100), precision: 2)
        end
        row(I18n.t('commission_value', scope: 'activerecord.labels.commissions'), &:commission_value)
        row :price_currency
      end
    end
    panel 'Promotional Products' do
      table_for shop.shop_promotions do
        column :time_of_start, label: :start
        column :time_of_end, label: :end
        column :price
        column :product_limit
      end
    end
  end

  csv do
    column :id
    column :image_exists do |item|
      if item.product
        item.product.photo.url != '/images/original/missing.png'
      else
        'Not found'
      end
    end
    column :product_name do |obj|
      if obj.product
        obj.product.name rescue 'Not found'
      else
        'Not found'
      end
    end
    column :retailer_name do |obj|
      if obj.retailer
        obj.retailer.company_name rescue 'Not found'
      else
        'Not found'
      end
    end
    column :price do |obj|
      number_with_precision((obj.price_dollars.to_f + obj.price_cents.to_f / 100), precision: 2)
    end
    column(I18n.t('commission_value_exception', scope: 'activerecord.labels.commissions'), &:commission_value)
    column :barcode do |obj|
      if obj.product
        obj.product.barcode rescue 'Not found'
      else
        'Not found'
      end
    end
    column :size_unit do |obj|
      if obj.product
        obj.product.size_unit rescue 'Not found'
      else
        'Not found'
      end
    end
    column :shelf_life do |obj|
      if obj.product
        obj.product.shelf_life rescue 'Not found'
      else
        'Not found'
      end
    end
    column :created_at
    column :category do |item|
      if item.product
        item.categories.map(&:name).uniq.join(', ') rescue nil
      else
        Product.unscoped.find_by(id: item.product_id).categories.map(&:name).uniq.join(', ') rescue nil
      end
    end
    column :subcategory do |item|
      if item.product
        item.subcategories.map(&:name).uniq.join(', ') rescue nil
      else
        Product.unscoped.find_by(id: item.product_id).subcategories.map(&:name).uniq.join(', ') rescue nil
      end
    end
    column :brand do |item|
      item.brand.name unless item.brand.nil?
    end
    column :is_published
    column :is_available
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Basic details' do
      f.input :retailer, collection: Retailer.pluck(:company_name, :id)
      # f.input :product, collection: Product.pluck(:name, :id)
      f.input :product_id
      # f.li "<label class='label'>Product</label><span>#{f.object.product.try(:name) || '-'}</span>".html_safe
      f.input :commission_value, label: (I18n.t('commission_value', scope: 'activerecord.labels.commissions'))
      # f.input :price_dollars, label: (I18n.t('price_unit', scope: 'activerecord.labels.shop'))
      # f.input :price_cents, label: (I18n.t('price_fraction', scope: 'activerecord.labels.shop'))
      f.input :price_dollars
      f.input :price_cents
      f.input :price_currency
      f.input :product_rank
      f.input :is_published, hint: 'Permanent'
      f.input :is_available, hint: 'Temporary'
      f.input :is_promotional
      f.input :promotion_only
      # f.input :promotion_only
      # f.object.owner_for_log = current_admin_user
      # f.input :owner_for_log, as: :hidden
      f.has_many :shop_promotions, heading: 'Shop Promotions', new_record: 'Add New', name: false, allow_destroy: false do |cf|
        cf.input :time_of_start, as: :date_time_picker
        cf.input :time_of_end, as: :date_time_picker
        cf.input :price
        cf.input :product_limit
      end
    end
    f.actions
  end

  controller do
    def create
      set_params
      super
    end

    def edit
      @page_title = I18n.t('product_in_shop', scope: 'activerecord.labels.shop')
    end

    def update
      shop = Shop.unscoped.not_oos.find_by_id(params[:id])
      if shop
        set_params
        super
      else
        false
      end
    end

    def set_params
      params[:shop][:detail] = {}
      params[:shop][:detail][:owner_type] = current_admin_user.class.name
      params[:shop][:detail][:owner_id] = current_admin_user.id
      if params[:shop][:shop_promotions_attributes].present?
        params[:shop][:shop_promotions_attributes].transform_values do |pa|
          pa[:retailer_id] = params[:shop][:retailer_id]
          pa[:product_id] = params[:shop][:product_id]
          pa[:start_time] = (("#{pa[:time_of_start]}".to_time.utc).to_f * 1000).floor
          pa[:end_time] = (("#{pa[:time_of_end]}".to_time.utc).to_f * 1000).floor
        end
      end
    end
  end
end
