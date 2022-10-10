# frozen_string_literal: true

ActiveAdmin.register RetailerType do
  menu parent: 'Retailers'
  actions :all, except: [:destroy]
  permit_params :name, :description, :bg_color, :priority, translations: {}, image_attributes: %i[id record_type record_id priority photo _destroy]

  remove_filter :image, :retailers

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Basic details' do
      f.input :name_en
      f.input :name_ar
      f.input :priority
      f.input :bg_color, as: :string
      f.inputs '', for: [:image, f.object.image || Image.new(priority: 0)] do |img|
        img.input :id, as: :boolean, label: 'Photo file size must be under 2mbs', input_html: { disabled: true }
        img.input :photo, as: :file
      end
      f.input :description_en
      f.input :description_ar
    end
    f.actions
  end

  index do
    column :name
    column :description
    column :bg_color
    column :priority
    actions
  end

  show do
    attributes_table :name_en, :name_ar, :priority, :description_en, :description_ar, :bg_color, :created_at, :updated_at do
      row :image do |img|
        image_tag img.image.photo_url('icon'), height: '100' if img.image&.photo
      end
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
      params[:retailer_type][:translations] = {}
      params[:retailer_type][:name] = params[:retailer_type][:name_en]
      params[:retailer_type][:translations][:name_en] = params[:retailer_type][:name_en]
      params[:retailer_type][:translations][:name_ar] = params[:retailer_type][:name_ar]
      params[:retailer_type][:description] = params[:retailer_type][:description_en]
      params[:retailer_type][:translations][:description_en] = params[:retailer_type][:description_en]
      params[:retailer_type][:translations][:description_ar] = params[:retailer_type][:description_ar]
    end
  end

end
