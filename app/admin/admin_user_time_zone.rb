# frozen_string_literal: true

ActiveAdmin.register AdminUser, as: 'change_current_time_zone' do
  menu false
  config.batch_actions = false
  config.filters = false
  actions :all, except: %i[new destroy]
  permit_params :current_time_zone

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Basic details' do
      f.input :current_time_zone, as: :select, collection: Retailer.time_zones.keys
    end
    f.actions
  end

  controller do
    def edit
      session[:my_previous_url] = URI(request.referer || '').path
      super
    end

    def update
      @admin_user = AdminUser.find_by_id(params[:id])
      @admin_user.update(permitted_params[:admin_user])
      redirect_target = session[:my_previous_url].blank? ? admin_change_current_time_zone_path : session[:my_previous_url]
      if @admin_user.save
        redirect_to redirect_target
      else
        render :edit
      end
    end
  end
end
