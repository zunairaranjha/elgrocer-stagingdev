# frozen_string_literal: true

ActiveAdmin.register Recipe do
  menu parent: 'Recipe'

  permit_params :name, :prep_time, :cook_time, :description, :chef_id, :photo, :is_published, :for_people, :deep_link,
                :slug, :seo_data, :priority, :recipe_category_id, :retailer_ids, :retailer_group_ids, :store_type_ids,
                :exclude_retailer_ids, recipe_category_ids: [], translations: {},
                ingredients_attributes: [:id, :product_id, :recipe_id, :qty, :qty_unit, :_destroy, translations: {}],
                cooking_steps_attributes: [:id, :step_number, :step_detail, :photo, :time, :recipe_id, :_destroy, translations: {}],
                images_attributes: %i[id record_type record_id priority photo _destroy]

  # remove_filter :cooking_steps, :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at, :description, :ingredients, :slugs
  filter :id
  filter :name
  filter :chef_id, label: 'Chef Id'
  filter :recipe_category_id, label: 'Recipe Category Id'
  filter :is_published
  filter :slug
  filter :storyly_slug
  filter :priority
  filter :created_at
  filter :updated_at
  # actions :all #, except: [:destroy]

  controller do
    def scoped_collection
      super.includes :recipe_categories, :chef # , ingredients: :product
    end
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    # products = Product.joins(:shops).pluck(:name, :id)
    # products = Product.pluck(:name, :id)
    f.object.recipe_retailer_ids = resource.retailer_ids.join(',')
    f.object.recipe_exclude_retailer_ids = resource.exclude_retailer_ids.join(',')
    f.object.recipe_store_type_ids = resource.store_type_ids.join(',')
    f.object.recipe_retailer_group_ids = resource.retailer_group_ids.join(',')
    f.inputs 'Basic details' do
      f.input :name_en
      f.input :name_ar
      f.input :priority
      f.li '<label></label><span>Photo file size must be under 2mbs</span>'.html_safe
      f.input :photo, as: :file, hint: image_tag(f.object.photo.url(:icon))
      f.input :recipe_categories, as: :select, collection: RecipeCategory.all.map { |c| [c.name_and_id, c.id] }
      f.input :prep_time, hint: 'Enter time in minutes. e.g 60'
      # f.input :cook_time, hint: 'Enter time in minutes. e.g 60'
      f.input :for_people
      f.input :description_en
      f.input :description_ar
      f.input :chef
      f.input :recipe_retailer_ids, as: :string, label: 'Retailer Ids', hint: 'Enter comma separated Retailer Ids e.g. 16,178,534'
      f.input :select_all_retailers, as: :boolean, label: 'Select All Retailers', input_html: { onclick: "$('#recipe_retailer_ids option').prop('selected', $('#select_all_retailers')[0].checked);", id: 'select_all_retailers' }
      f.input :recipe_exclude_retailer_ids, as: :string, label: 'Exclude Retailer Ids', hint: 'Enter comma separated Retailer Ids e.g. 16,178,534'
      f.input :recipe_retailer_group_ids, as: :string, label: 'Retailer Group Ids', hint: 'Enter comma separated Retailer Group Ids e.g. 1,2,3'
      f.input :recipe_store_type_ids, as: :string, label: 'Store Type Ids', hint: 'Enter comma separated Store Type Ids e.g. 1,2,3'
      f.input :deep_link
      f.input :slug
      f.input :is_published
      f.input :seo_data
      f.has_many :images, heading: 'Recipe Images', new_record: 'Add New', name: false, allow_destroy: true do |img|
        img.input :priority
        img.input :id, as: :boolean, label: 'Photo file size must be under 2mbs', input_html: { disabled: true }
        img.input :photo, as: :file, hint: image_tag(img.object.photo.url(:icon))
      end
      # products = Product.order(:name, :id)
      f.has_many :ingredients, heading: 'Ingredients', new_record: 'Add New', name: false, allow_destroy: true do |cf|
        cf.input :product_id # , as: :select, input_html: { class: "select2" }, collection: products
        cf.input :qty_en
        cf.input :qty_ar
        cf.input :qty_unit_en
        cf.input :qty_unit_ar
      end
      f.has_many :cooking_steps, heading: 'Cooking Steps', new_record: 'Add New', name: false, allow_destroy: true do |cf|
        cf.input :step_number
        cf.input :step_detail_en
        cf.input :step_detail_ar
        cf.input :time
        # cf.input :photo, as: :file
      end
    end
    f.actions
  end

  index do
    column :photo do |obj|
      image_tag(obj.photo.url(:icon))
    end
    column :name
    column :priority
    column :recipe_categories
    column :prep_time
    # column :cook_time
    column :for_people
    column :description
    column :chef
    column :deep_link
    column :slug
    column :is_published
    column :created_at
    column :updated_at
    actions
  end

  show do |obj|
    attributes_table :name_en, :name_ar do
      row :photo do
        image_tag(obj.photo_url('icon'), height: '100') if obj.photo
      end
      row :priority
      row :recipe_categories
      row :prep_time
      # row :cook_time
      row :for_people
      row :description_en
      row :description_ar
      row :chef
      row :deep_link
      row :slug
      row :storyly_slug
      row :is_published
      row :seo_data
      row :retailer_ids
      row :exclude_retailer_ids
      row :retailer_group_ids
      row :store_type_ids
      row :created_at
      row :updated_at
      row :images do
        div do
          obj.images.each do |img|
            li do
              image_tag img.photo_url('icon'), height: '100'
            end
          end
        end
      end
      panel 'Ingredients' do
        table_for recipe.ingredients.includes(:product) do
          column :product
          column :qty_en
          column :qty_ar
          column :qty_unit_en
          column :qty_unit_ar
        end
      end
      panel 'Cooking Steps' do
        table_for recipe.cooking_steps do
          column :photo do |p|
            image_tag(p.photo.url(:medium), height: '50') # if :photo
          end
          column :step_number
          column :step_detail_en
          column :step_detail_ar
          column :time
        end
      end
    end
  end

  controller do
    def create
      set_params
      super
      @recipe.update(storyly_slug: "recipe_#{@recipe.id}", deep_link: Firebase::LinkShortener.new.recipe_deep_link(@recipe.id))
      if @recipe.photo.present?
        r_image = @recipe.images.new(priority: 0)
        r_image.photo = @recipe.photo
        r_image.save
      end
      @recipe
    end

    def update
      set_params
      super
      unless @recipe.images.length.positive? and @recipe.photo.present?
        r_image = @recipe.images.new(priority: 0)
        r_image.photo = @recipe.photo
        r_image.save
      end
      @recipe
    end

    def set_params
      params[:recipe][:translations] = {}
      params[:recipe][:translations][:name_en] = params[:recipe][:name_en]
      params[:recipe][:translations][:name_ar] = params[:recipe][:name_ar]
      params[:recipe][:translations][:description_en] = params[:recipe][:description_en]
      params[:recipe][:translations][:description_ar] = params[:recipe][:description_ar]
      params[:recipe][:store_type_ids] = "{#{params[:recipe][:recipe_store_type_ids].split(',').map(&:to_i).join(',')}}"
      params[:recipe][:exclude_retailer_ids] = "{#{params[:recipe][:recipe_exclude_retailer_ids].split(',').map(&:to_i).join(',')}}"
      params[:recipe][:retailer_group_ids] = "{#{params[:recipe][:recipe_retailer_group_ids].split(',').map(&:to_i).join(',')}}"
      params[:recipe][:retailer_ids] = if params[:recipe][:select_all_retailers].to_i == 1
                                         Retailer.where(is_active: true).pluck(:id)
                                       else
                                         "{#{params[:recipe][:recipe_retailer_ids].split(',').map(&:to_i).join(',')}}"
                                       end
      params[:recipe][:recipe_category_id] = params[:recipe][:recipe_category_ids].reject(&:blank?).first
      params[:recipe][:ingredients_attributes]&.transform_values do |ds|
        ds[:qty] = ds[:qty_en]
        ds[:qty_unit] = ds[:qty_unit_en]
        ds[:translations] = {}
        ds[:translations][:qty_en] = ds[:qty_en]
        ds[:translations][:qty_ar] = ds[:qty_ar]
        ds[:translations][:qty_unit_en] = ds[:qty_unit_en]
        ds[:translations][:qty_unit_ar] = ds[:qty_unit_ar]
      end
      params[:recipe][:cooking_steps_attributes]&.transform_values do |ds|
        ds[:step_detail] = ds[:step_detail_en]
        ds[:translations] = {}
        ds[:translations][:step_detail_en] = ds[:step_detail_en]
        ds[:translations][:step_detail_ar] = ds[:step_detail_ar]
      end
    end
  end
end
