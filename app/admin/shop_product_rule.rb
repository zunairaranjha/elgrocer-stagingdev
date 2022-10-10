# frozen_string_literal: true

ActiveAdmin.register ShopProductRule do
  menu parent: "Products"
  permit_params :id, :at_day, :is_enable, :created_at, :updated_at, :at_time, :categories, :retailers, category_ids: [], retailer_ids: []

  scope :all
  remove_filter :shop_product_rule_categories
  remove_filter :shop_product_rule_retailers
  remove_filter :categories
  remove_filter :shop_product_logs

  index do
    column :categories do |rule|
      (rule.categories.pluck(:name)*(', ')).truncate(100)
    end
    column :retailers do |rule|
      (rule.retailers.pluck(:company_name)*(', ')).truncate(100)
    end
    column :at_day
    column :at_time # do |rule|
    #   rule.send_time.present? ? rule.send_time : 'N/A'
    # end
    column :is_enable
    actions
  end


  form do |f|
    f.inputs 'Create Schedule Rule' do
      f.input :categories, as: :select, :multiple => true, collection: Category.where('parent_id is not null').order(:name).all.map { |b| [ "#{b.id} : #{b.name}", b.id ] }
      f.input :retailers, as: :select, :multiple => true, collection: Retailer.where(is_active: true).order(:company_name).all.map { |b| [ "#{b.id} : #{b.company_name}", b.id ]}
      f.input :at_day
      f.input :at_time, :as => :select, :collection => (1..23).map { |t| "#{t.to_s.rjust(2, '0')}:00" }
      f.input :is_enable
    end
    f.actions
  end

  show do |rule|
    attributes_table do
      row :categories do |rule|
        rule.categories.pluck(:name)*(', ')
      end
      row :retailers do |rule|
        rule.retailers.pluck(:company_name)*(', ')
      end
      row :at_day
      row :at_time
      row :is_enable
    end
  end


 end
