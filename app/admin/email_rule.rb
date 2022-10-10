# frozen_string_literal: true

ActiveAdmin.register EmailRule do

  permit_params :id, :name, :days_for, :is_enable, :created_at, :updated_at, :send_time, :promotion_code_id, :category

  scope :all
  scope :enable

  index do
    column :category
    column :name
    column :days_for
    column :send_time do |rule|
      rule.send_time.present? ? rule.send_time : 'N/A'
    end
    column :promotion_code # do |rule|
      # rule.promotion_code.present? ? rule.promotion_code.name : 'N/A'
    # end
    column :is_enable
    actions
  end

  filter :name

  form do |f|
    f.inputs 'Create Email Rule' do
      f.input :category, :as => :select, :collection => ["Order Reminder", "Abandon Basket"]
      f.input :name
      f.input :days_for
      f.input :send_time, :as => :select, :collection => (1..23).map { |t| "#{t.to_s.rjust(2, '0')}:00" }
      f.input :promotion_code_id, :label => 'Promotion Code', :as => :select, :collection => PromotionCode.all.map { |pc| [pc.name, pc.id] }
      f.input :is_enable
    end
    f.actions
  end

  show do |code|
    attributes_table do
      row :category
      row :name
      row :days_for
      row :send_time
      row :promotion_code_id
      row :is_enable
    end
  end


end
