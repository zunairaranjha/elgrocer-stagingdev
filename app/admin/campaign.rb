# frozen_string_literal: true

ActiveAdmin.register Campaign do

  filter :id
  filter :name
  filter :by_location_in, label: 'Location', as: :select, collection: proc { controller.campaign_locations.map { |c| [c.key.split('.').last, c.value] } }
  filter :campaign_type, as: :select, collection: proc { controller.campaign_type.map { |c| [c.key.split('.').last, c.value] } }

  index do
    column :id
    column :name
    column :priority
    column :campaign_type do |code|
      controller.campaign_type.select { |c| c.value.to_i == code.campaign_type }.first&.key.to_s.split('.').last
    end
    column :locations do |code|
      controller.campaign_locations.select { |c| code.locations.include? c.value.to_i }.map { |c| c.key.split('.').last }
    end
    column :retailer_ids do |code|
      (code.retailer_ids.join(',')).truncate(30)
    end
    column :store_type_ids do |code|
      (code.store_type_ids.join(',')).truncate(30)
    end
    column :retailer_group_ids do |code|
      (code.retailer_group_ids.join(',')).truncate(30)
    end
    column :start_time
    column :end_time
    actions
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.object.campaign_locations = resource.locations
    f.object.campaign_category_ids = resource.category_ids.join(',')
    f.object.campaign_subcategory_ids = resource.subcategory_ids.join(',')
    f.object.campaign_brand_ids = resource.brand_ids.join(',')
    f.object.campaign_retailer_ids = resource.retailer_ids.join(',')
    f.object.campaign_exclude_retailer_ids = resource.exclude_retailer_ids.join(',')
    f.object.campaign_store_type_ids = resource.store_type_ids.join(',')
    f.object.campaign_retailer_group_ids = resource.retailer_group_ids.join(',')
    f.object.campaign_product_ids = resource.product_ids.join(',')
    f.object.campaign_keywords = resource.keywords.join(',')
    # f.object.start_time = resource.start_time.to_time - 4.hours if resource.start_time
    # f.object.end_time = resource.end_time.to_time - 4.hours if resource.end_time
    f.inputs 'Basic details' do
      f.input :name
      f.input :name_ar
      f.input :start_time, as: :date_time_picker, hint: "As per '#{current_admin_user.current_time_zone}' TimeZone"
      f.input :end_time, as: :date_time_picker, hint: "As per '#{current_admin_user.current_time_zone}' TimeZone"
      f.input :priority
      f.input :campaign_type, as: :select, collection: controller.campaign_type.map { |c| [c.key.split('.').last, c.value] }
      f.input :campaign_locations, as: :select, multiple: true, collection: controller.campaign_locations.map { |c| [c.key.split('.').last, c.value] }
      f.input :campaign_category_ids, as: :string, label: 'Category Ids', hint: 'Enter comma separated Category Ids e.g. 90,80,67'
      f.input :campaign_subcategory_ids, as: :string, label: 'Subcategory Ids', hint: 'Enter comma separated Subcategory Ids e.g. 100,110,117'
      f.input :campaign_brand_ids, as: :string, label: 'Brand Ids', hint: 'Enter comma separated Brand Ids e.g. 5667,7888,8989'
      f.input :campaign_retailer_ids, as: :string, label: 'Retailer Ids', hint: 'Enter comma separated Retailer Ids e.g. 16,178,534'
      f.input :select_all_retailers, as: :boolean, label: 'Select All Retailers', input_html: { onclick: "$('#campaign_retailer_ids option').prop('selected', $('#select_all_retailers')[0].checked);", id: 'select_all_retailers' }
      f.input :campaign_exclude_retailer_ids, as: :string, label: 'Exclude Retailer Ids', hint: 'Enter comma separated Retailer Ids e.g. 16,178,534'
      f.input :campaign_store_type_ids, as: :string, label: 'Store Type Ids', hint: 'Enter comma separated Store Type Ids e.g. 1,2,3'
      f.input :campaign_retailer_group_ids, as: :string, label: 'Retailer Group Ids', hint: 'Enter comma separated Retailer Group Ids e.g. 1,2,3'
      f.input :campaign_product_ids, as: :string, label: 'Product Ids', hint: 'Enter comma separated Product Ids e.g. 4256,7798,1234'
      f.input :campaign_keywords, as: :string, label: 'Keywords', hint: 'Enter comma separated keywords e.g. milk,butter,water'
      f.input :url, hint: 'Enter destination url to redirect app to e.g. https://www.elgrocer.com'
      f.input :photo, as: :file
      f.input :photo_ar, as: :file
      f.input :banner, as: :file
      f.input :banner_ar, as: :file
      f.input :web_photo, as: :file
      f.input :web_photo_ar, as: :file
      f.input :web_banner, as: :file
      f.input :web_banner_ar, as: :file
    end
    f.actions
  end

  show do
    attributes_table :name, :name_ar, :priority do
      row :campaign_type do |code|
        controller.campaign_type.select { |c| c.value.to_i == code.campaign_type }.first&.key.to_s.split('.').last
      end
      row :locations do |code|
        controller.campaign_locations.select { |c| code.locations.include? c.value.to_i }.map { |c| c.key.split('.').last }
      end
      row :category_ids do |code|
        code.category_ids.join(', ')
      end
      row :subcategory_ids do |code|
        code.subcategory_ids.join(', ')
      end
      row :brand_ids do |code|
        code.brand_ids.join(', ')
      end
      row :retailer_ids do |code|
        code.retailer_ids.join(', ')
      end
      row :exclude_retailer_ids do |code|
        code.exclude_retailer_ids.join(', ')
      end
      row :store_type_ids do |code|
        code.store_type_ids.join(', ')
      end
      row :retailer_group_ids do |code|
        code.retailer_group_ids.join(', ')
      end
      row :product_ids do |code|
        code.product_ids.join(', ')
      end
      row :keywords do |code|
        code.keywords.join(', ')
      end
      row :url
      row :start_time
      row :end_time
      row :created_at
      row :updated_at
      row :photo do |p|
        image_tag(p.photo.url(:icon), height: '50')
      end
      row :photo_ar do |p|
        image_tag(p.photo_ar.url(:icon), height: '50')
      end
      row :banner do |p|
        image_tag(p.banner.url(:icon), height: '50')
      end
      row :banner_ar do |p|
        image_tag(p.banner_ar.url(:icon), height: '50')
      end
      row :web_photo do |p|
        image_tag(p.web_photo.url(:icon), height: '50')
      end
      row :web_photo_ar do |p|
        image_tag(p.web_photo_ar.url(:icon), height: '50')
      end
      row :web_banner do |p|
        image_tag(p.web_banner.url(:icon), height: '50')
      end
      row :web_banner_ar do |p|
        image_tag(p.web_banner_ar.url(:icon), height: '50')
      end
    end
  end

  controller do
    def create
      if params[:campaign][:start_time].blank? and params[:campaign][:end_time].blank?
        super
        return
      end
      parameter = {
        name: params[:campaign][:name],
        name_ar: params[:campaign][:name_ar],
        priority: params[:campaign][:priority],
        campaign_type: params[:campaign][:campaign_type]
      }
      @campaign = Campaign.new(parameter)
      @campaign.photo = params[:campaign][:photo]
      @campaign.photo_ar = params[:campaign][:photo_ar]
      @campaign.banner = params[:campaign][:banner]
      @campaign.banner_ar = params[:campaign][:banner_ar]
      @campaign.web_photo = params[:campaign][:web_photo]
      @campaign.web_photo_ar = params[:campaign][:web_photo_ar]
      @campaign.web_banner = params[:campaign][:web_banner]
      @campaign.web_banner_ar = params[:campaign][:web_banner_ar]
      @campaign.start_time = params[:campaign][:start_time]
      @campaign.end_time = params[:campaign][:end_time]
      @campaign.locations = "{#{params[:campaign][:campaign_locations].reject(&:blank?).map(&:to_i).join(',')}}"
      @campaign.store_type_ids = "{#{params[:campaign][:campaign_store_type_ids].split(',').map(&:to_i).join(',')}}"
      @campaign.exclude_retailer_ids = "{#{params[:campaign][:campaign_exclude_retailer_ids].split(',').map(&:to_i).join(',')}}"
      @campaign.retailer_group_ids = "{#{params[:campaign][:campaign_retailer_group_ids].split(',').map(&:to_i).join(',')}}"
      @campaign.keywords = "{#{params[:campaign][:campaign_keywords]}}"
      @campaign.category_ids = "{#{params[:campaign][:campaign_category_ids].split(',').map(&:to_i).join(',')}}"
      @campaign.subcategory_ids = "{#{params[:campaign][:campaign_subcategory_ids].split(',').map(&:to_i).join(',')}}"
      @campaign.brand_ids = "{#{params[:campaign][:campaign_brand_ids].split(',').map(&:to_i).join(',')}}"
      @campaign.product_ids = "{#{params[:campaign][:campaign_product_ids].split(',').map(&:to_i).join(',')}}"
      @campaign.url = params[:campaign][:url]
      @campaign.retailer_ids = if params[:campaign][:select_all_retailers].to_i == 1
                                 Retailer.where(is_active: true).pluck(:id)
                               else
                                 "{#{params[:campaign][:campaign_retailer_ids].split(',').map(&:to_i).join(',')}}"
                               end
      if @campaign.valid?
        @campaign.save
        redirect_to admin_campaign_path(id: @campaign.id), flash: { notice: 'Campaign has been created!' }
      else
        super
      end
    end

    def update
      if params[:campaign][:start_time].blank? and params[:campaign][:end_time].blank?
        super
        return
      end
      campaign = Campaign.find_by(id: params[:id])
      campaign[:name] = params[:campaign][:name]
      campaign[:priority] = params[:campaign][:priority]
      campaign.name_ar = params[:campaign][:name_ar]
      campaign.campaign_type = params[:campaign][:campaign_type]
      campaign.photo = params[:campaign][:photo] if params[:campaign][:photo].present?
      campaign.photo_ar = params[:campaign][:photo_ar] if params[:campaign][:photo_ar].present?
      campaign.banner = params[:campaign][:banner] if params[:campaign][:banner].present?
      campaign.banner_ar = params[:campaign][:banner_ar] if params[:campaign][:banner_ar].present?
      campaign.web_photo = params[:campaign][:web_photo] if params[:campaign][:web_photo].present?
      campaign.web_photo_ar = params[:campaign][:web_photo_ar] if params[:campaign][:web_photo_ar].present?
      campaign.web_banner = params[:campaign][:web_banner] if params[:campaign][:web_banner].present?
      campaign.web_banner_ar = params[:campaign][:web_banner_ar] if params[:campaign][:web_banner_ar].present?
      campaign.start_time = params[:campaign][:start_time]
      campaign.end_time = params[:campaign][:end_time]
      campaign.locations = "{#{params[:campaign][:campaign_locations].reject(&:blank?).map(&:to_i).join(',')}}"
      campaign.store_type_ids = "{#{params[:campaign][:campaign_store_type_ids].split(',').map(&:to_i).join(',')}}"
      campaign.exclude_retailer_ids = "{#{params[:campaign][:campaign_exclude_retailer_ids].split(',').map(&:to_i).join(',')}}"
      campaign.retailer_group_ids = "{#{params[:campaign][:campaign_retailer_group_ids].split(',').map(&:to_i).join(',')}}"
      campaign.keywords = "{#{params[:campaign][:campaign_keywords]}}"
      campaign.category_ids = "{#{params[:campaign][:campaign_category_ids].split(',').map(&:to_i).join(',')}}"
      campaign.subcategory_ids = "{#{params[:campaign][:campaign_subcategory_ids].split(',').map(&:to_i).join(',')}}"
      campaign.brand_ids = "{#{params[:campaign][:campaign_brand_ids].split(',').map(&:to_i).join(',')}}"
      campaign.product_ids = "{#{params[:campaign][:campaign_product_ids].split(',').map(&:to_i).join(',')}}"
      campaign.url = params[:campaign][:url]
      campaign.retailer_ids = if params[:campaign][:select_all_retailers].to_i == 1
                                Retailer.where(is_active: true).pluck(:id)
                              else
                                "{#{params[:campaign][:campaign_retailer_ids].split(',').map(&:to_i).join(',')}}"
                              end
      if campaign.save
        redirect_to admin_campaign_path(id: campaign.id), flash: { notice: 'Campaign has been successfully updated!' }
      else
        super
      end
    end

    def campaign_type
      @campaign_type ||= SystemConfiguration.where("key ilike 'campaign_type.%'")
    end

    def campaign_locations
      @campaign_locations ||= SystemConfiguration.where("key ilike 'campaign_location.%'")
    end
  end
end
