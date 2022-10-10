# frozen_string_literal: true

ActiveAdmin.register Shopper do
  menu parent: 'Shoppers'

  permit_params :name, :phone_number, :email, :password, :password_confirmation, :device_type, :authentication_token, :is_blocked, :is_smiles_user, :is_deleted

  index do
    column :name
    column :email
    column :phone_number
    column :created_at
    column(I18n.t('current_sign_in_at', scope: 'activerecord.labels.session'), &:current_sign_in_at)
    column :sign_in_count
    column :is_blocked
    column 'Logged in On Smiles', &:is_smiles_user
    column :is_deleted
    column :platform_type
    actions
  end

  filter :id
  filter :name
  filter :phone_number
  filter :email
  filter :referred_by
  filter :is_blocked
  filter :is_smiles_user, label: 'Logged in On Smiles'
  filter :platform_type, as: :select, collection: { 'elgrocer' => 0, 'smiles' => 1 }
  filter :is_deleted
  filter :language, as: :select, collection: { 'en' => 0, 'ar' => 1 }
  filter :date_time_offset

  show do |shopper|
    attributes_table :name,
                     :email,
                     :phone_number,
                     :app_version,
                     :created_at,
                     :sign_in_count,
                     :device_type,
                     :registration_id,
                     :is_blocked,
                     :is_deleted,
                     :date_time_offset,
                     :average_basket_value,
                     :platform_type do
      row 'Logged in On Smiles' do
        shopper.is_smiles_user
      end
      row I18n.t(:last_login, scope: ['activerecord', 'labels', 'shopper']) do
        shopper.current_sign_in_at
      end
      row :orders do
        link_to 'see all', admin_orders_path(q: { shopper_id_eq: shopper.id })
      end
      row :reviews do
        link_to 'see all', admin_reviews_path(q: { shopper_id_eq: shopper.id })
      end
      row :shopper_addresses do
        link_to 'see all', admin_shopper_addresses_path(q: { shopper_id_eq: shopper.id })
      end
      row :shopper_cart_products do
        link_to "see all(#{shopper.shopper_cart_products.count})", admin_shopper_cart_products_path(q: { shopper_id_eq: shopper.id })
      end
      row :credit_cards do
        link_to "see all(#{shopper.credit_cards.count})", admin_credit_cards_path(q: { shopper_id_eq: shopper.id })
      end
    end
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Basic details' do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :phone_number, hint: 'Enter Phone Number with country code'
      f.input :is_blocked
      f.input :block_shopper, :as => :boolean, :label => 'Invalidate Current Session', :input_html => { :onclick => "$('#shopper_block_shopper_input option').prop('selected', $('#block_shopper')[0].checked);", :id => 'block_shopper' }
    end
    f.actions
  end

  controller do
    def update
      params['shopper']['phone_number'] = params['shopper']['phone_number'].phony_normalized
      if params[:shopper][:password].blank? && params[:shopper][:password_confirmation].blank?
        params[:shopper].delete('password')
        params[:shopper].delete('password_confirmation')
      end
      if params[:shopper][:block_shopper].eql?('1')
        params[:shopper][:authentication_token] = generate_authentication_token
      end
      if params[:shopper][:is_blocked].eql?('0')
        Redis.current.del "#{params[:shopper][:email]}"
      end
      super
    end

    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless Shopper.where(authentication_token: token).exists?
      end
    end
  end
end
