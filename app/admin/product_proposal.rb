# frozen_string_literal: true

ActiveAdmin.register ProductProposal do
  menu parent: 'Products'
  actions :all, except: %i[new destroy]
  includes :brand, :image


  permit_params :barcode, :name, :order_id, :type_id, :status_id

  index do
    column :id
    column :photo do |obj|
      image_tag(obj.photo_url(:icon)) if obj.image&.photo
    end
    column :order_id
    column :name
    column :barcode
    column :size_unit
    column :brand
    column :oos_product_id
    column :status_id
    column :type_id
    column :created_at
    column :updated_at
    actions
  end

  filter :order_id
  filter :barcode
  filter :name
  filter :oos_product_id
  filter :status_id, as: :select, multiple: true, collection: ProductProposal.status_ids
  filter :type_id, as: :select, multiple: true, collection: ProductProposal.type_ids
  show do |pp|
    attributes_table :id, :order_id, :name, :size_unit, :barcode, :description, :slug, :created_at do
      row :status_id
      row :type_id
      row :oos_product_id
      row :photo do
        image_tag(pp.photo_url, height: '100') if pp.image&.photo
      end
      row :brand do
        pp.brand.name rescue ''
      end
      row('categories') do
        pp.subcategories.map(&:name).join(', ')
      end

    end
  end
  #
  #   panel I18n.t(:product_in_shop, :scope => ["activerecord", "labels", "product"]) do
  #     table_for Shop.unscoped.includes(:retailer).where(product_id: product) do
  #       column("ID") { |c| link_to(c.id, admin_shop_path(c.id)) }
  #       column('Retailer name') { |c| link_to(c.retailer.company_name, admin_retailer_path(c.retailer_id)) }
  #       column('Price') { |c| (c.price_dollars.to_f + c.price_cents.to_f/100) }
  #       column :is_published
  #       column :is_available
  #     end
  #   end
  # end
  #
  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Basic details' do
      f.input :order_id, input_html: { disabled: true }
      f.input :name, input_html: { disabled: true }
      f.input :barcode, input_html: { disabled: true }
      f.input :type_id, input_html: { disabled: true }
      f.input :status_id, as: :select, collection: ProductProposal.status_ids
    end
    f.actions
  end

end
