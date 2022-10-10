# frozen_string_literal: true

ActiveAdmin.register Employee do
  menu parent: "Employee"
  permit_params :user_name, :password, :name, :phone_number, :activity_status, :is_active, :active_roles, :retailer_id
  includes :retailer
  actions :all, except: [:destroy]

  filter :retailer_id, label: 'Retailer ID'
  filter :user_name
  filter :name
  filter :phone_number
  filter :is_active
  filter :by_active_roles, label: 'Active Role', as: :select, collection: proc { controller.roles }
  filter :created_at
  filter :updated_at

  index do
    column :id
    column :name
    column :user_name
    column :phone_number
    column :retailer
    column :activity_status
    column(:active_roles){ |c| controller.roles.select{|role| c.active_roles.include? role.id }.map(&:name).join(', ') }
    column :is_active
    actions
  end

  show do |employee|
    attributes_table do
      row :name
      row :user_name
      row 'Password' do
        '*********'
      end
      row :phone_number
      row :retailer
      row :activity_status
      row :active_roles do
        controller.roles.select{|role| employee.active_roles.include? role.id }.map(&:name).join(', ')
      end
      row :created_at
      row :updated_at
      row :is_active
    end
  end

  form do |f|
    f.inputs 'Employee Details' do
      f.input :name
      f.input :user_name
      f.input :password
      f.input :phone_number
      f.input :active_roles, as: :check_boxes, collection: controller.roles
      f.input :retailer
      f.input :is_active
    end
    f.actions
  end

  controller do
    def create
      roles = params[:employee][:active_roles].reject(&:blank?)
      unless roles.blank?
        params[:employee][:active_roles] = "{#{roles.map(&:to_i).join(',')}}"
      end
      super
    end

    def update
      if params[:employee][:password].blank?
        params[:employee].delete("password")
      end
      roles = params[:employee][:active_roles].reject(&:blank?)
      if roles.blank?
        params[:employee][:active_roles] = '{}'
      else
        params[:employee][:active_roles] = "{#{roles.map(&:to_i).join(',')}}"
      end
      super
    end

    def roles
      @roles ||= EmployeeRole.where("name NOT ILIKE '%deliver%'")
    end
  end

  end
