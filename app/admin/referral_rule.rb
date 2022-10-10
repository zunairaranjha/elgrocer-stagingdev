# frozen_string_literal: true

ActiveAdmin.register ReferralRule do
  menu parent: "Settings"
permit_params :id, :name, :expiry_days, :referrer_amount, :referee_amount, :event_id, :message,:message_ar, :is_active, :created_at, :updated_at, city_ids: []
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

scope :all
scope :active

  index do
    column :name
    column :expiry_days 
    column :referrer_amount
    column :referee_amount
    column :event_id
    column :cities
    column :message
    column :is_active
    actions
  end

  filter :name

  form do |f|
    f.inputs 'Create Referral Rule' do
      f.input :name
      f.input :expiry_days 
      f.input :referrer_amount
      f.input :referee_amount
      f.input :event_id
      f.input :cities, as: :select, collection: City.all.map { |s| [s.name, s.id] }
      f.input :message, hint: 'tags: [NAME], [URL]'
      f.input :message_ar, hint: 'tags: [NAME], [URL]'
      f.input :is_active
    end
    f.actions
  end


end
