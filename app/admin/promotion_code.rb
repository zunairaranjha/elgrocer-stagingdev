# frozen_string_literal: true

ActiveAdmin.register PromotionCode do
  menu parent: 'Promotion Codes', label: 'Codes'

  permit_params :value_cents, :code, :allowed_realizations, :start_date, :end_date, :min_basket_value, :order_limit, :all_brands, :all_retailers, :percentage_off, :reference, :promotion_type,
                :retailer_service_id, :realizations_per_shopper, :realizations_per_retailer,
                :title_en, :title_ar, :description_en, :description_ar, :name_en, :name_ar,
                shopper_ids: [], retailer_ids: [], brand_ids: [], available_payment_type_ids: [], data: {},
                image_attributes: %i[id record_type record_id priority photo _destroy]

  actions :all, except: [:destroy]

  index do
    # res = PromotionCode.joins(:retailers).pluck(:id, :company_name)
    column :code
    column :value do |code|
      "#{humanized_money(code.value)} AED"
    end
    column :promotion_type
    column :description
    # column :retailers do |code|
    #   ret = res.select{|s| s[0] == code.id}
    #   ret.map{|c| c[1]}*(', ')
    #   code.retailers.pluck(:company_name)*(', ')
    # end
    column :allowed_realizations
    column :start_date
    column :end_date
    column :reference
    actions
  end

  filter :code
  filter :retailers
  filter :value_cents
  filter :allowed_realizations
  filter :start_date
  filter :end_date
  filter :reference

  form do |f|
    f.inputs 'Promotion Code Details' do
      f.input :value_cents, label: I18n.t('value', scope: 'activerecord.labels.promotion_code')
      f.input :percentage_off, hint: 'Percentage off should be integer e.g for 10% it should be 10'
      f.input :code, label: I18n.t('code', scope: 'activerecord.labels.promotion_code')
      f.input :promotion_type
      f.input :name_en
      f.input :name_ar
      f.input :title_en
      f.input :title_ar
      f.input :description_en
      f.input :description_ar
      f.input :allowed_realizations, label: I18n.t('allowed_realizations', scope: 'activerecord.labels.promotion_code')
      f.input :realizations_per_shopper, hint: I18n.t('promotion_codes.realizations_hint')
      f.input :realizations_per_retailer, hint: I18n.t('promotion_codes.realizations_hint')
      f.input :min_basket_value, hint: '0 - Unlimited'
      f.input :order_limit, hint: '0 for New Users, Range: N-M orders (10-100)'
      f.input :start_date, as: :datepicker, label: I18n.t('start_date', scope: 'activerecord.labels.promotion_code')
      f.input :end_date, as: :datepicker, label: I18n.t('end_date', scope: 'activerecord.labels.promotion_code')
      f.input :shopper_ids, as: :string, hint: '(If empty code will be for all shoppers) Please enter comma Separated ids e.g. 20,35099'
      f.input :retailer_service_id, label: 'Service Type', hint: 'If not selected code will be for all services', as: :select, collection: RetailerService.pluck(:name, :id)
      f.input :available_payment_types, as: :check_boxes, member_label: Proc.new { |apt| I18n.t(apt.name, scope: 'activerecord.labels.locations', default: apt.name) }
      f.input :retailers, as: :select, input_html: { class: 'select2' }, collection: Retailer.where(is_active: true).pluck(:company_name, :id)
      # f.input :select_all_retailers, as: :boolean, label: 'Select All Retailers', input_html: { onclick: "$('#promotion_code_retailer_ids option').prop('selected', $('#select_all_retailers')[0].checked);", id: "select_all_retailers" }
      f.input :all_retailers, :label => 'Select All Retailers'
      f.input :brands, as: :select, input_html: { class: 'select2' }, collection: Brand.order(:name).pluck(:name, :id)
      f.input :all_brands, label: 'Select All Brands'
      f.input :reference
      f.inputs '', for: [:image, f.object.image || Image.new(priority: 0)] do |img|
        img.input :id, as: :boolean, label: 'Photo file size must be under 2mbs', input_html: { disabled: true }
        if img.object.photo.present?
          img.input :photo, as: :file, hint: img.template.image_tag(img.object.photo.url(:thumb))
        else
          img.input :photo, as: :file
        end
      end
      # li do
      #   link_to 'Select All Brands', '#promotion_code_brand_ids', onclick: "selectAll('promotion_code_brand_ids')"
      # end
    end
    f.actions
  end

  show do |code|
    attributes_table do
      row 'Value' do
        "#{humanized_money(code.value)} #{code.value_currency}"
      end
      row :percentage_off do
        "#{code.percentage_off} %" if code.percentage_off.present?
      end
      row :code
      row :promotion_type
      row :name_en
      row :name_ar
      row :title_en
      row :title_ar
      row :description_en
      row :description_ar
      row :allowed_realizations
      row :realizations_per_shopper
      row :realizations_per_retailer
      row :min_basket_value
      row :order_limit
      row :start_date
      row :end_date
      row :shopper_ids
      row 'Service Type' do
        if code.retailer_service_id.to_i > 0
          code.retailer_service_id.to_i > 1 ? 'Click and Collect' : 'Delivery'
        else
          'All'
        end
      end
      row ('Available payment types') do
        promotion_code.available_payment_types.map { |apt| I18n.t(apt.name, scope: ['activerecord', 'labels', 'locations'], default: apt.name) }.join(', ')
      end
      row :reference
      row :image do |obj|
        image_tag(obj.photo_url, height: 100) if obj.image
      end
      row :retailers do
        code.all_retailers ? Retailer.where(is_active: true).pluck(:company_name) * (', ') : code.retailers.pluck(:company_name) * (', ')
      end
      row :brands do
        code.all_brands ? Brand.pluck(:name) * (', ') : code.brands.pluck(:name) * (', ')
      end
      row :realizations do
        link_to 'Show all', admin_promotion_code_realizations_path(q:
                                                                     { promotion_code_id_eq: code.id })
      end
    end
  end

  controller do
    def create
      parameters = {
        value_cents: params[:promotion_code][:value_cents],
        percentage_off: params[:promotion_code][:percentage_off],
        shopper_ids: params[:promotion_code][:shopper_ids].scan(/\d+/),
        retailer_service_id: params[:promotion_code][:retailer_service_id],
        code: params[:promotion_code][:code],
        promotion_type: params[:promotion_code][:promotion_type],
        allowed_realizations: params[:promotion_code][:allowed_realizations],
        start_date: params[:promotion_code][:start_date],
        end_date: params[:promotion_code][:end_date],
        realizations_per_shopper: params[:promotion_code][:realizations_per_shopper],
        realizations_per_retailer: params[:promotion_code][:realizations_per_retailer],
        min_basket_value: params[:promotion_code][:min_basket_value],
        order_limit: params[:promotion_code][:order_limit],
        all_brands: params[:promotion_code][:all_brands],
        all_retailers: params[:promotion_code][:all_retailers],
        reference: params[:promotion_code][:reference]
      }
      @promo_code = PromotionCode.new(parameters)
      @promo_code[:data] = {}
      @promo_code[:data][:title_en] = params[:promotion_code][:title_en]
      @promo_code[:data][:title_ar] = params[:promotion_code][:title_ar]
      @promo_code[:data][:name_en] = params[:promotion_code][:name_en]
      @promo_code[:data][:name_ar] = params[:promotion_code][:name_ar]
      @promo_code[:data][:description_en] = params[:promotion_code][:description_en]
      @promo_code[:data][:description_ar] = params[:promotion_code][:description_ar]
      @promo_code.save
      if @promo_code.valid?
        # @promo_code.save
        PromotionCode.transaction do
          # promo = promotion_code_create!
          create_available_payment_types!(@promo_code.id)
          create_promotion_code_retailers(@promo_code.id)
          create_brand_promotion_code(@promo_code.id)
          if params[:promotion_code][:image_attributes].present?
            img = Image.new
            img.photo = params[:promotion_code][:image_attributes][:photo]
            img.record = @promotion_code
            img.save
          end
        end
        redirect_to admin_promotion_code_path(id: @promo_code.id), flash: { notice: 'Promotion Code has been created!' }
      else
        # redirect_to new_admin_promotion_code_path, flash: { errors: "Promotion Code has been created!" }
        super
      end
    end

    def update
      promotion_code = PromotionCode.find_by(id: params[:id])
      promotion_code[:value_cents] = params[:promotion_code][:value_cents]
      promotion_code[:code] = params[:promotion_code][:code]
      promotion_code[:promotion_type] = params[:promotion_code][:promotion_type]
      promotion_code[:data] = {}
      promotion_code[:data][:title_en] = params[:promotion_code][:title_en]
      promotion_code[:data][:title_ar] = params[:promotion_code][:title_ar]
      promotion_code[:data][:name_en] = params[:promotion_code][:name_en]
      promotion_code[:data][:name_ar] = params[:promotion_code][:name_ar]
      promotion_code[:data][:description_en] = params[:promotion_code][:description_en]
      promotion_code[:data][:description_ar] = params[:promotion_code][:description_ar]
      promotion_code[:allowed_realizations] = params[:promotion_code][:allowed_realizations]
      promotion_code[:start_date] = params[:promotion_code][:start_date]
      promotion_code[:end_date] = params[:promotion_code][:end_date]
      promotion_code[:realizations_per_shopper] = params[:promotion_code][:realizations_per_shopper]
      promotion_code[:realizations_per_retailer] = params[:promotion_code][:realizations_per_retailer]
      promotion_code[:min_basket_value] = params[:promotion_code][:min_basket_value]
      promotion_code[:order_limit] = params[:promotion_code][:order_limit]
      promotion_code[:all_brands] = params[:promotion_code][:all_brands]
      promotion_code[:all_retailers] = params[:promotion_code][:all_retailers]
      promotion_code[:percentage_off] = params[:promotion_code][:percentage_off]
      promotion_code[:shopper_ids] = params[:promotion_code][:shopper_ids].scan(/\d+/)
      promotion_code[:retailer_service_id] = params[:promotion_code][:retailer_service_id]
      promotion_code[:reference] = params[:promotion_code][:reference]
      if promotion_code.save
        PromotionCode.transaction do
          promotion_code_update(promotion_code)
          create_available_payment_types!(promotion_code.id)
          create_promotion_code_retailers(promotion_code.id)
          create_brand_promotion_code(promotion_code.id)
          if params[:promotion_code][:image_attributes].present? && params[:promotion_code][:image_attributes][:photo].present?
            img = promotion_code.image.present? ? Image.find_by(id: promotion_code.image.id) : Image.new
            img.photo = params[:promotion_code][:image_attributes][:photo]
            img.record = promotion_code
            img.save
          end
        end
        redirect_to admin_promotion_code_path(id: promotion_code.id), flash: { notice: 'Promotion Code has been successfully updated!' }
      else
        super
      end
    end

    def promotion_code_update(promotion_code)
      # update_params = {}
      # update_params[:value_cents] = params[:promotion_code][:value_cents]
      # update_params[:code] = params[:promotion_code][:code]
      # update_params[:allowed_realizations] = params[:promotion_code][:allowed_realizations]
      # update_params[:start_date] = params[:promotion_code][:start_date]
      # update_params[:end_date] = params[:promotion_code][:end_date]
      # update_params[:realizations_per_shopper] = params[:promotion_code][:realizations_per_shopper]
      # update_params[:realizations_per_retailer] = params[:promotion_code][:realizations_per_retailer]
      # update_params[:min_basket_value] = params[:promotion_code][:min_basket_value]
      # promotion_code.update(update_params)
      ActiveRecord::Base.connection.execute("DELETE FROM promotion_code_available_payment_types WHERE promotion_code_id = #{promotion_code.id}")
      ActiveRecord::Base.connection.execute("DELETE FROM promotion_codes_retailers WHERE promotion_code_id = #{promotion_code.id}")
      ActiveRecord::Base.connection.execute("DELETE FROM brands_promotion_codes WHERE promotion_code_id = #{promotion_code.id}")
    end

    def promotion_code_create!
      parameters = {
        value_cents: params[:promotion_code][:value_cents],
        code: params[:promotion_code][:code],
        allowed_realizations: params[:promotion_code][:allowed_realizations],
        start_date: params[:promotion_code][:start_date],
        end_date: params[:promotion_code][:end_date],
        realizations_per_shopper: params[:promotion_code][:realizations_per_shopper],
        realizations_per_retailer: params[:promotion_code][:realizations_per_retailer],
        min_basket_value: params[:promotion_code][:min_basket_value]
      }
      promo_code = PromotionCode.create!(parameters)
    end

    def create_available_payment_types!(promo_id)
      available_payment_types = params[:promotion_code][:available_payment_type_ids].reject(&:blank?)
      available_payment_types.each do |ap_id|
        PromotionCodeAvailablePaymentType.create!(promotion_code_id: promo_id, available_payment_type_id: ap_id)
      end
    end

    def create_promotion_code_retailers(promo_id)
      if params[:promotion_code][:all_retailers].to_i < 1 && !(retailer_ids = params[:promotion_code][:retailer_ids].reject(&:blank?)).blank?
        # retailers = Retailer.where(is_active: true).ids if retailers.blank? # select active retailers if no retailer was selected.
        values = retailer_ids.map { |u| "(#{promo_id},#{u})" }.join(',')
        ActiveRecord::Base.connection.execute("INSERT INTO promotion_codes_retailers (promotion_code_id, retailer_id) VALUES #{values}")
      else
        PromotionCode.where(id: promo_id).update_all(all_retailers: true)
      end
    end

    def create_brand_promotion_code(promo_id)
      if params[:promotion_code][:all_brands].to_i < 1 && !(brand_ids = params[:promotion_code][:brand_ids].reject(&:blank?)).blank?
        values = brand_ids.map { |u| "(#{promo_id},#{u})" }.join(',')
        ActiveRecord::Base.connection.execute("INSERT INTO brands_promotion_codes (promotion_code_id, brand_id) VALUES #{values}")
      else
        PromotionCode.where(id: promo_id).update_all(all_brands: true)
      end
    end
  end
end
