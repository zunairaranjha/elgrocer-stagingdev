# frozen_string_literal: true

ActiveAdmin.register Order do
  actions :all, except: %i[new destroy]
  includes :retailer_service, :promotion_code_realization, :delivery_slot, :delivery_channel
  permit_params :status_id, :retailer_id, :shopper_id, :is_approved, :accepted_at, :updated_at, :processed_at,
                :total_commission, :user_canceled_type, :message, :delivery_channel_id, :estimated_delivery_at, :delivery_slot_id

  before_action :adjust_filter, only: :index

  # scope :all
  # scope :orders_pending
  # scope :orders_accepted
  # scope :orders_en_route
  # scope :orders_delivered
  # scope :orders_completed
  # scope :with_promotion_code
  # scope :without_promotion_code
  # scope :with_wallet_amount_paid
  # scope :orders_instant
  # scope :orders_scheduled

  config.sort_order = 'created_at_desc'

  index do
    # panel "General information", :id => "foo-panel" do
    #   l_module = DashboardService
    #   date_from = nil
    #   date_to = nil
    #   if params[:q]
    #     date_from = params[:q][:created_at_gteq]
    #     date_to = params[:q][:created_at_lteq]
    #   end
    #   ul do
    #     li "All orders count: " + Order.count.to_s
    #     li "Orders count for given period (as created_at): " + l_module.orders_count_for_period(date_from, date_to).to_s
    #     li 'Total commissions collected: ' + l_module.total_income.to_s
    #     li 'Total commissions collected in this month: ' + l_module.current_month_total_income.to_s
    #     li 'Total commissions collected for given period: ' + l_module.total_income_for_period(date_from, date_to).to_s
    #     li 'Total paid from wallet for given period: ' + l_module.total_paid_from_wallet_for_period(date_from, date_to).to_s
    #   end
    #
    # end
    column :id
    column('Shopper name') { |c| link_to(c.shopper_name.present? && c.shopper_name || c.shopper_id, admin_shopper_path(c.shopper_id)) rescue c.shopper_name }
    column('Retailer Name') { |c| link_to(c.retailer_company_name, admin_retailer_path(c.retailer_id)) rescue c.retailer_company_name }
    column I18n.t(:total_price, scope: %w[activerecord labels order]) do |order|
      order.total_value.to_f.round(2)
      # op = order.order_positions
      # value_sum = 0
      # op.each do |position|
      #   value_sum += ((position.shop_price_dollars + (position.shop_price_cents).to_f/100).to_f).round(2) * position.amount
      # end
      # number_with_precision(value_sum.round(2), :precision => 2)
    end
    column :status
    column :created_at
    column 'Promotion?' do |order|
      status_tag order.promotion_code_realization.present?
    end
    column :delivery_channel
    column :delivery_vehicle
    # column 'Wallet' do |order|
    #   order.wallet_amount_paid && order.wallet_amount_paid.to_f.round(2)
    # end
    column 'Delivery at', :estimated_delivery_at
    column 'Delivery Slot', :delivery_slot
    column :retailer_service
    column 'Delivered With Driver App' do |order|
      DRIVER_PILOT_RETAILER_IDS.include?(order.retailer_id) && [1, 2].include?(order.payment_type_id)
    end
    column :platform_type
    actions do |order|
      link_to('Reschedule', edit_admin_reschedule_order_path(order.id)) unless [3, 4, 5].include? order.status_id
    end
  end

  filter :id
  filter :shopper_id, label: 'Shopper ID'
  filter :shopper_name, label: I18n.t(:shopper_name, scope: %w[activerecord labels order])
  filter :retailer_id_includes, as: :string, label: 'Retailer ID'
  filter :retailer_company_name, label: I18n.t(:retailer_company_name, scope: %w[activerecord labels order])
  filter :retailer_service_id, as: :select, collection: RetailerService.all
  filter :status_id, as: :select, multiple: true, collection: Order.statuses
  filter :created_at, label: I18n.t(:date, scope: %w[activerecord labels order])
  filter :language, as: :select, collection: { 'en' => 0, 'ar' => 1 }
  filter :device_type, as: :select, collection: Order.device_types
  filter :payment_type_id, as: :select, collection: AvailablePaymentType.all
  filter :platform_type, as: :select, collection: { 'elgrocer' => 0, 'smiles' => 1 }
  filter :estimated_delivery_at, as: :date_time_range, label: 'Delivery at'
  filter :hours_eq, as: :number, label: 'Hours', hint: 'Show all orders that have delivery time under Current Time + given Hours'
  filter :delivery_slot_id
  filter :delivery_channel, as: :select, collection: proc { controller.delivery_channels }
  filter :auto_refresh_trigger, label: 'auto refresh seconds', as: :select, collection: [30, 60, 120, 180]

  show do |order|
    panel 'Order Details' do
      attributes_table_for order do
        row :shopper_name
        row :retailer_company_name
        row :created_at
        row :status
        row :processed_at
        row :accepted_at
        row :updated_at
        row :is_approved
        row :shopper_note
        row :wallet_amount_paid
        row :delivery_slot_id
        row :retailer_delivery_zone
        row :estimated_delivery_at
        row :approved_at
        row :payment_type
        row :delivery_fee
        row :rider_fee
        row :service_fee
        row :vat
        row :device_type
        row :price_variance
        row :final_amount
        row :merchant_reference
        row :auth_amount do
          order.card_detail['auth_amount'].to_i / 100.0 if order.card_detail
        end
        row :delivery_vehicle
        row :app_version
        row :platform_type
        row :retailer_service do
          order.retailer_service&.name
        end
        row :shopper_time_zone do
          order.date_time_offset
        end
        row 'Substitution Preference' do
          order.orders_datum.detail['substitution_preference_value'] rescue nil
        end
        row 'Shopper Suggestion' do
          order.orders_datum.detail['suggestion'] rescue nil
        end
        row 'Receipt Image' do
          div do
            order.image&.each do |img|
              li do
                link_to('Click here to view Image', img.photo_url(:large))
              end
            end
          end
        end
      end
    end

    if order.promotion_code_realization.present?
      panel 'Promotion code' do
        attributes_table_for order do
          row 'Promotion code' do
            link_to 'Code details', [:admin, order.promotion_code_realization.promotion_code]
          end
          row :promotion_code_realization do
            link_to 'Realization details', [:admin, order.promotion_code_realization]
          end
          row 'Value' do
            "#{((
              if order.promotion_code_realization.discount_value.to_i.positive?
                order.promotion_code_realization.discount_value
              else
                order.promotion_code_realization.promotion_code.value_cents
              end) / 100.0).round(2)} #{order.promotion_code_realization.promotion_code.value_currency}"
          end
        end
      end
    end

    # panel 'Shopper Feedback' do
    #   attributes_table_for order do
    #     row :is_on_time
    #     row :is_accurate
    #     row :is_price_same
    #     row :feedback_comments
    #   end
    # end

    panel 'Statuses' do
      attributes_table_for order do
        row :status
        row :is_approved
        row :accepted_at
        row :processed_at
        row :approved_at
        row :user_canceled_type
        row(I18n.t('message', scope: 'activerecord.labels.order')) do
          order.message
        end
        row :feedback_status
        row :order_feedback
      end
    end

    panel 'Order delivery address' do
      attributes_table_for order do
        row :shopper_address_area
        row :shopper_address_street
        row :shopper_address_building_name
        row :shopper_address_apartment_number
        row :shopper_address_type
        row :shopper_address_name
        row 'Coordinates' do
          "Latitude: #{order.shopper_address_latitude}, Longitude: #{order.shopper_address_longitude}"
        end
        row :shopper_address_location_address
        row :shopper_address_location_name
        row :shopper_address_floor
        row :shopper_address_house_number
        row :shopper_address_additional_direction
        if order.shopper_address.present?
          row 'shopper_address' do
            link_to order.shopper_address.street_address, [:admin, order.shopper_address]
          end
        end
        row :delivery_channel
      end
    end

    panel 'Click and Collect Details' do
      attributes_table_for order do
        oc = order.order_collection_detail
        row 'Collector_Detail' do
          collector = oc&.collector_detail

          "#{collector.name}, #{collector.phone_number}" if collector.present?
        end

        row 'Vehicle_Detail' do
          vehicle_detail = oc&.vehicle_detail

          if vehicle_detail.present?
            vehicle_model = vehicle_detail.vehicle_model
            vehicle_color = vehicle_detail.color
            "#{vehicle_detail.plate_number}, #{vehicle_model.name}, #{vehicle_detail.company}, #{vehicle_color.name}"
          end
        end

        row 'Pickup_Location_Detail' do
          pickup_detail = oc&.pickup_location
          (pickup_detail&.details).to_s
        end

        row 'Pickup_Location_Detail_Ar' do
          pickup_detail = oc&.pickup_location
          (pickup_detail&.details_ar).to_s
        end

        row 'Pickup_Location_Lonlat' do
          pickup_detail = oc&.pickup_location
          (pickup_detail&.lonlat).to_s

        end

        row 'Pickup_Location_photo' do
          pickup_detail = oc&.pickup_location
          image_tag(pickup_detail&.photo&.url(:medium), height: '50') if pickup_detail.present?
        end
      end
    end

    panel 'Order positions' do
      table_for order.order_positions do
        # column('Product') { |c| link_to(c.product_name, admin_product_path(c.product_id)) rescue c.product_name }
        column('Product') do |c|
          if c.product_id.to_i.positive?
            link_to(c.product_name, admin_product_path(c.product_id)) rescue c.product_name
          else
            link_to(c.product_name, admin_product_proposal_path(c.product_proposal_id)) rescue c.product_name
          end
        end
        column :was_in_shop
        column "Quantity (#{order.order_positions.sum(:amount)})", :amount
        column "Full Price (#{order.order_positions.to_a.sum(&:full_standard_price).round(2)})", :full_standard_price
        column "Promotional Price (#{order.order_positions.to_a.sum(&:full_promo_price).round(2)})", :full_promo_price do |obj|
          obj.full_promo_price.positive? ? obj.full_promo_price : 'NA'
        end
        column :shop_price_currency
        column 'Time Zone', :date_time_offset
      end
    end

    panel 'Order Substitution' do
      table_for order.order_substitutions.includes(:product, :substituting_product) do
        column('OOS Product') { |c| link_to(c.product.name, admin_product_path(c.product.id)) rescue c.product.name }
        column('Suggested Product') do |c|
          if c.product_proposal_id.to_i.positive?
            link_to(c.product_proposal&.name, admin_product_proposal_path(c.product_proposal_id)) rescue c.product_proposal&.name
          else
            link_to(c.substituting_product&.name, admin_product_path(c.substituting_product_id)) rescue c.substituting_product&.name
          end
        end
        column :is_selected
        column 'Time Zone', :date_time_offset
      end
    end
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Status' do
      f.input :status_id, as: :select, collection: Order.statuses
      f.input :is_approved
      f.input :accepted_at, as: :datepicker
      f.input :processed_at, as: :datepicker
      f.input :delivery_slot_id
      f.input :estimated_delivery_at, as: :datepicker
      f.input :message, label: 'Cancel Reason'
      f.input :delivery_channel_id, as: :select, collection: DeliveryChannel.all
    end
    f.actions
  end

  csv do
    Order.attribute_names.each { |name|
      column name.to_sym
    }
    # column :total_commission
    column :total_price
    column :delivery_slot do |item|
      item.delivery_slot.try(:name)
    end
    column 'delivered_with_driver_app' do |order|
      DRIVER_PILOT_RETAILER_IDS.include?(order.retailer_id) && [1, 2].include?(order.payment_type_id)
    end
  end

  controller do
    def update
      # status_id = params[:order][:status_id]
      is_approved = params[:order][:is_approved]
      params[:order][:updated_at] = Time.now
      # case status_id
      # when 1
      #  unless params[:order][:accepted_at]
      #    params[:order][:accepted_at] = Time.new
      #  end
      # when 2
      #  unless params[:order][:processed_at]
      #    params[:order][:processed_at] = Time.new
      #  end
      # when 3
      #  unless params[:order][:approved_at]
      #    params[:order][:approved_at] = Time.new
      #  end
      # end
      params[:order][:approved_at] = Time.new if is_approved
      if params[:order][:status_id].to_i == 4
        params[:order][:user_canceled_type] = 3
        PromotionCodeRealization.where(order_id: params[:id]).delete_all
      end
      super
    end

    def delivery_channels
      @delivery_channels ||= [DeliveryChannel.new(id: 0, name: 'Unassign')] + DeliveryChannel.all
    end

    def adjust_filter
      params['q']['hours_eq'] = "#{params['q']['hours_eq']}.0" if params['q'] && params['q']['hours_eq']
    end
  end

end
