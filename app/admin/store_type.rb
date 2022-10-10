# frozen_string_literal: true

ActiveAdmin.register StoreType do
  menu parent: 'Retailers'
  # includes :retailers
  actions :all, except: [:destroy]

  permit_params :name, :name_ar, :priority, :bg_color, :photo, retailer_ids: [],
                image_attributes: %i[id record_type record_id priority photo _destroy]

  index do
    panel 'Note: Please Do not tag any retailer with All Stores!'
    column :photo do |obj|
      image_tag(obj.photo.url(:icon))
    end
    column :color_photo do |obj|
      image_tag(obj.image&.photo_url('icon')) if obj.image
    end
    column :name
    column :name_ar
    column :priority
    column :bg_color
    # column :retailers do |obj|
    #   obj.retailers.pluck(:company_name)*(', ')
    # end
    actions
  end

  filter :name

  form do |f|
    f.inputs 'Store Type Detail' do
      f.input :name
      f.input :name_ar
      f.input :priority
      f.input :bg_color, as: :string
      f.input :photo, as: :file
      f.inputs 'Color Photo', for: [:image, f.object.image || Image.new(priority: 0)] do |img|
        img.input :id, as: :boolean, label: 'Photo file size must be under 2mbs', input_html: { disabled: true }
        img.input :photo, as: :file
      end
      f.input :retailers, as: :select, input_html: { class: 'select2' }, collection: Retailer.all.pluck(:company_name, :id)
    end
    f.actions
  end

  show do |obj|
    attributes_table do
      row :name
      row :name_ar
      row :priority
      row :bg_color
      row :photo do
        image_tag(obj.image_url, height: '100') if obj.photo
      end
      row :color_photo do
        image_tag(obj.image.photo.url, height: '100') if obj.image
      end
      row :retailers do
        obj.retailers.pluck(:company_name) * (', ')
      end
    end
  end

  controller do
    def create
      retailers = params[:store_type][:retailer_ids].reject(&:blank?)
      params[:store_type] = params[:store_type].except(:retailer_ids) unless retailers.blank?
      super

      unless retailers.blank?
        values = retailers.map { |u| "(#{u},#{@store_type.id})" }.join(',')
        ActiveRecord::Base.connection.execute("INSERT INTO retailer_store_types (retailer_id, store_type_id) VALUES #{values}")
      end
    end

    def update
      RetailerStoreType.where(store_type_id: params[:id]).delete_all
      retailers = params[:store_type][:retailer_ids].reject(&:blank?)
      params[:store_type] = params[:store_type].except(:retailer_ids)
      unless retailers.blank?
        values = retailers.map { |u| "(#{u},#{params[:id]})" }.join(',')
        ActiveRecord::Base.connection.execute("INSERT INTO retailer_store_types (retailer_id, store_type_id) VALUES #{values}")
      end
      super
    end
  end
end
