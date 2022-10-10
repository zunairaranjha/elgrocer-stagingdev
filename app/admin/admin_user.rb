# frozen_string_literal: true

ActiveAdmin.register AdminUser do
  menu parent: 'Access Rights'
  includes :role
  permit_params :email, :password, :password_confirmation, :role_id, :current_time_zone

  index do
    selectable_column
    id_column
    column(I18n.t('email', scope: 'activerecord.labels.user'), &:email)
    column(I18n.t('current_sign_in_at', scope: 'activerecord.labels.session'), &:current_sign_in_at)
    column(I18n.t('sign_in_count', scope: 'activerecord.labels.session'), &:sign_in_count)
    column(I18n.t('created_at', scope: 'activerecord.labels.user'), &:created_at)
    column :current_time_zone
    column :role
    actions
  end

  filter :email, label: I18n.t('email', scope: 'activerecord.labels.user')
  filter :current_sign_in_at, label: I18n.t('current_sign_in_at', scope: 'activerecord.labels.session')
  filter :sign_in_count, label: I18n.t('sign_in_count', scope: 'activerecord.labels.session')
  filter :created_at, label: I18n.t('created_at', scope: 'activerecord.labels.user')
  filter :role

  form do |f|
    f.inputs 'Admin Details' do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :current_time_zone, as: :select, collection: Retailer.time_zones.keys
      f.input :role if current_admin_user.role_id == 1
    end
    f.actions
  end

  controller do
    def update
      if params[:admin_user][:password].blank? && params[:admin_user][:password_confirmation].blank?
        params[:admin_user].delete('password')
        params[:admin_user].delete('password_confirmation')
      end
      super
      # params[:admin_user].email = params[:admin_user][:email]
      # params[:admin_user].role_id = params[:admin_user][:role]

    end
  end
end
