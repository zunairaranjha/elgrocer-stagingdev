# frozen_string_literal: true

ActiveAdmin.register Retailer do
  menu parent: 'Retailers'
  includes :available_payment_types

  permit_params :email, :password, :password_confirmation, :is_active, :is_opened, :send_tax_invoice, :is_generate_report, :is_report_add_email, :is_report_add_phone, :report_emails, :report_parent_id,
                :delivery_type_id, :delivery_slot_skip_hours, :cutoff_time, :schedule_order_reminder_hours, :company_name_ar, :company_address_ar,
                :company_name, :company_address, :location_id, :contact_email, :phone_number, :opening_time, :latitude, :longitude, :photo, :photo1,
                :delivery_range, :delivery_notes, :delivery_team_commitment, :number_of_deliveries_per_hour_commitment, :date_time_offset, :is_featured,
                :store_owner_name, :store_owner_phone_number, :store_owner_email, :commission_value, :show_pending_order_hours, :retailer_group_id, :with_stock_level,
                :store_manager_name, :store_manager_phone_number, :store_manager_email, :delivery_zones_select, :is_show_brand, :service_fee, :retailer_type, :seo_data, :store_types,
                :is_show_recipe, :integration_level, :notes, :slug, :ret_category_ids, :select_all_rcategories, available_payment_type_ids: [], location_ids: [], delivery_zone_ids: [], banner_ids: [], delivery_payment_type_ids: [], click_and_collect_payment_type_ids: [],
                retailer_has_services: %i[id retailer_id retailer_service_id service_fee delivery_slot_skip_time cutoff_time min_basket_value schedule_order_reminder_time is_active delivery_type],
                delivery_service: %i[id retailer_id retailer_service_id service_fee delivery_slot_skip_time cutoff_time min_basket_value schedule_order_reminder_time is_active delivery_type],
                click_and_collect_service: %i[id retailer_id retailer_service_id service_fee delivery_slot_skip_time cutoff_time min_basket_value schedule_order_reminder_time is_active delivery_type],
                image_attributes: %i[id record_type record_id priority photo _destroy]

  filter :email
  filter :company_name
  filter :phone_number
  filter :is_active
  filter :is_opened
  filter :is_show_brand
  filter :delivery_type_id
  filter :available_payment_types
  filter :date_time_offset, label: 'TimeZone'
  filter :with_stock_level
  filter :is_featured
  filter :send_tax_invoice

  scope :all
  scope :opened
  scope :closed
  scope :active_closed
  scope :is_generate_report

  # controller do
  #   def scoped_collection
  #     super.includes :available_payment_types
  #   end
  # end

  index do
    column(I18n.t('email', scope: 'activerecord.labels.user'), &:email)
    column(I18n.t('company_name', scope: 'activerecord.labels.retailer'), &:company_name)
    column :slug
    # column(I18n.t('total_income', scope: 'activerecord.labels.commissions')) { |c| c.total_income}
    # column(I18n.t('current_month_income', scope: 'activerecord.labels.commissions')) { |c| c.current_month_income}
    column(I18n.t('commission_value', scope: 'activerecord.labels.commissions'), &:commission_value)
    column(I18n.t('available_payment_types', scope: 'activerecord.labels.retailer')) { |c| c.available_payment_types.map { |apt| I18n.t(apt.name, scope: %w[activerecord labels locations]) }.join(', ') }
    column :with_stock_level
    column(I18n.t('current_sign_in_at', scope: 'activerecord.labels.session'), &:current_sign_in_at)
    column(I18n.t('sign_in_count', scope: 'activerecord.labels.session'), &:sign_in_count)
    column(I18n.t('created_at', scope: 'activerecord.labels.user'), &:created_at)
    actions
  end

  show do |retailer|
    panel I18n.t(:retailer_details, scope: %w[activerecord labels retailer]) do
      attributes_table_for retailer do
        [:email].each do |f|
          row f
        end
        row :password do
          '************'
        end
        row :is_active
        row :is_opened
        row :is_show_brand
        row :is_show_recipe
        row :retailer_types
        row :show_pending_order_hours
        row :retailer_group
        row 'TimeZone' do
          retailer.date_time_offset
        end
        row :with_stock_level
        row :is_featured
        row 'Store type' do
          retailer.store_types.map(&:name).join(', ')
        end
        row :seo_data
        row :send_tax_invoice
      end
    end

    panel 'Order Reports' do
      attributes_table_for retailer do
        row :is_generate_report
        row :is_report_add_email
        row :is_report_add_phone
        row :report_parent_id
        row :report_emails
      end
    end

    panel 'Schedule Order' do
      attributes_table_for retailer do
        row :delivery_type
        # row :delivery_slot_skip_time
        # row :order_cutoff_time
        # row :schedule_order_reminder_time
      end
    end

    panel I18n.t(:store_details, scope: %w[activerecord labels retailer]) do
      attributes_table_for retailer do
        %i[company_name company_name_ar slug commission_value company_address company_address_ar location contact_email phone_number latitude longitude].each do |f|
          row f
        end
        row :map do
          lat = retailer.latitude.to_s
          lng = retailer.longitude.to_s
          coords = retailer.delivery_areas_json
          '' "
            <script src='https://maps.googleapis.com/maps/api/js?key=AIzaSyBvJex_MXaq5D3UeM9vmfAMJ35mfct0jlA'></script>
            <div id='map' style='width: 100%; height: 300px;'></div>
            <script>
              function initialize(){
                google.maps.Polygon.prototype.getBounds = function() {
                  var bounds = new google.maps.LatLngBounds();
                  var paths = this.getPaths();
                  var path;
                  for (var i = 0; i < paths.getLength(); i++) {
                      path = paths.getAt(i);
                      for (var ii = 0; ii < path.getLength(); ii++) {
                          bounds.extend(path.getAt(ii));
                      }
                  }
                  return bounds;
                };
                var map = new google.maps.Map(document.getElementById('map'), {
                  zoom: 12,
                  center: {lat: 24.386, lng: 54.272},
                  mapTypeId: google.maps.MapTypeId.TERRAIN
                });
                var pos = new google.maps.LatLng(#{lat}, #{lng});
                console.log(#{coords});
                var polygonCoords = #{coords};
                var deliveryZone = new google.maps.Polygon({
                  paths: polygonCoords,
                  strokeColor: '#FF0000',
                  strokeOpacity: 0.8,
                  strokeWeight: 2,
                  fillColor: '#FF0000',
                  fillOpacity: 0.35
                });
                var marker = new google.maps.Marker({
                  position: pos,
                  map: map
                });
                marker.setMap(map);
                map.fitBounds(deliveryZone.getBounds());
                deliveryZone.setMap(map);
              }
              google.maps.event.addDomListener(window, 'load', initialize);
            </script>
          " ''.html_safe
        end
        row :photo do
          image_tag(retailer.photo.url, height: '100') if retailer.photo
        end
        row :background_image_en do
          image_tag(retailer.photo1.url, height: '100') if retailer.photo1
        end
        row :background_image_ar do
          image_tag(retailer.image.photo.url, height: '100') if retailer.image
        end
        row :opening_time do
          retailer.human_opening_time.html_safe
        end
        row :products do
          link_to 'see all', admin_shops_path(q: { retailer_id_eq: retailer.id })
        end
        row :csv_imports do
          link_to 'see all', admin_csv_imports_path(q: { retailer_id_eq: retailer.id })
        end
        # row :add_new_csv_import do
        #   link_to "Add link", new_csv_import_path(csv_import: {retailer_id: retailer.id})
        # end
      end
    end

    panel 'Delivery Details' do
      attributes_table_for retailer.delivery_service do
        row :is_active
        row 'Available payment types' do
          retailer.delivery_payment_types.map { |apt| I18n.t(apt.name, scope: %w[activerecord labels locations]) }.join(', ')
        end
        row :service_fee
        # row :delivery_slot_skip_hours
        # row :order_cutoff_time
        row :schedule_order_reminder_hours
      end
      attributes_table_for retailer do
        row :delivery_range
        row :delivery_notes
        row :delivery_team_commitment
        row :number_of_deliveries_per_hour_commitment
      end
    end

    panel I18n.t(:delivery_zones, scope: %w[activerecord labels retailer]) do

      attributes_table_for retailer do
        row :delivery_zones do
          link_to 'see all', admin_retailer_delivery_zones_path(q: { retailer_id_eq: retailer.id })
        end
        row :delivery_zones do
          link_to 'Add a zone', new_admin_retailer_delivery_zone_path(retailer_id: retailer.id)
        end
        table_for retailer.retailer_delivery_zones.includes(:delivery_zone) do
          column('Name') { |c| c.delivery_zone.try(:name) }
          column('Minimum Basket Value', &:min_basket_value)
          column :delivery_fee
          column :rider_fee
          column do |rdz|
            link_to 'View', [:admin, rdz]
          end
          column do |rdz|
            link_to 'Edit', [:edit_admin, rdz]
          end
        end
      end
    end

    panel 'Locations' do
      attributes_table_for retailer do
        row :locations do
          link_to 'see all', admin_retailer_has_locations_path(q: { retailer_id_eq: retailer.id })
        end
        row :locations do
          link_to 'Add a location', new_admin_retailer_has_location_path(retailer_id: retailer.id)
        end
        table_for retailer.retailer_has_locations.includes(:location) do
          column('Name') { |c| c.location.name }
          column do |rhl|
            link_to 'View', [:admin, rhl]
          end
          column do |rhl|
            link_to 'Edit', [:edit_admin, rhl]
          end
        end
      end
    end

    panel 'Click and Collect Details' do
      attributes_table_for retailer.click_and_collect_service do
        row :is_active
        row 'Available payment types' do
          retailer.click_and_collect_payment_types.map { |apt| I18n.t(apt.name, scope: %w[activerecord labels locations]) }.join(', ')
        end
        row :service_fee
        row :min_basket_value
        row :delivery_type
        row :delivery_slot_skip_hours
        row :order_cutoff_time
        row :schedule_order_reminder_hours
        row :click_and_collect_slots do
          link_to 'View', admin_click_and_collect_slot_path(id: retailer.id)
        end
      end
    end

=begin
    panel 'Promotion codes' do
      attributes_table_for retailer do
        row :promotion_codes do
          link_to 'See all', admin_promotion_codes_path(q: { retailers_id_eq: retailer.id })
        end
        row :promotion_code_realizations do
          link_to 'See all', admin_promotion_code_realizations_path(q: { retailer_id_eq: retailer.id })
        end
        row 'Total value of promotion codes realizations' do
          total = Money.new(0, 'AED')
          retailer.promotion_codes.find_each do |code|
            total += code.realizations_value_per_retailer(retailer.id)
          end
          "#{humanized_money(total)} AED"
        end

        panel 'Per code info' do
          table_for retailer.promotion_codes do
            column('Code') { |c| c.code }
            column('Value') { |c| "#{humanized_money(c.value)} AED" }
            column('Number of realizations') { |c| c.realizations.successful.where(retailer_id: retailer.id).count }
            column('Total value of realizations') { |c| "#{humanized_money(
              c.realizations_value_per_retailer(retailer.id))} AED" }
            column do |code|
              link_to 'Code details', [:admin, code]
            end
            column do |code|
              link_to 'List of realizations',
                admin_promotion_code_realizations_path(q: {
                  retailer_id_eq: retailer.id, promotion_code_id_eq: code.id
                })
            end
          end
        end
      end
    end

    panel "Banners" do
      table_for retailer.banners do
        column :title
        column :subtitle
        column :desc
        # column :color
        # column :group
        # column :priotity
        column :start_date
        column :end_date
        column do |b|
          link_to 'View', [:admin, b]
        end
        column do |b|
          link_to 'Edit', [:edit_admin, b]
        end
      end
    end
=end

    panel I18n.t(:store_reviews, scope: %w[activerecord labels retailer]) do
      attributes_table_for retailer do
        row :average_rating
        row :reviews do
          link_to 'see all', admin_reviews_path(q: { retailer_id_eq: retailer.id })
        end
      end
    end

    panel I18n.t('commissions', scope: 'activerecord.labels.commissions') do
      attributes_table_for retailer do
        row(I18n.t('total_income', scope: 'activerecord.labels.commissions')) do
          retailer.total_income
        end
        row(I18n.t('current_month_income', scope: 'activerecord.labels.commissions')) do
          retailer.current_month_income
        end
        row(I18n.t('commission_value', scope: 'activerecord.labels.commissions')) do
          retailer.commission_value
        end
        row(I18n.t('commission_exceptions', scope: 'activerecord.labels.commissions')) do
          link_to 'see all', admin_shops_path(q: { retailer_id_eq: retailer.id }, scope: :particular_commission_value)
        end
      end
    end

    %w[owner manager].each do |title|
      panel I18n.t("#{title}_details", scope: %w[activerecord labels retailer]) do
        attributes_table_for retailer do
          %W[store_#{title}_name store_#{title}_phone_number store_#{title}_email].each do |f|
            row f
          end
        end
      end
    end

    panel I18n.t(:integration_level, scope: %w[activerecord labels retailer]) do
      attributes_table_for retailer do
        row :integration_level
      end
    end

    panel I18n.t(:additional_notes, scope: %w[activerecord labels retailer]) do
      attributes_table_for retailer do
        row :notes
      end
    end

    panel 'Categories' do
      attributes_table_for retailer do
        row :categories do
          Category.joins(:retailer_categories).where(retailer_categories: { retailer_id: retailer.id }).pluck(:name) * (', ')
        end
      end
    end

    # panel I18n.t(:devices, :scope => ["activerecord", "labels", "retailer"]) do
    #   attributes_table_for retailer do
    #     table_for retailer.retailer_operators do
    #       column('hardware_id') { |c| c.hardware_id }
    #       column('device') { |c| c.device }
    #       column('registration_id') { |c| c.registration_id }
    #     end
    #   end
    # end
  end

  form do |f|
    f.object.ret_category_ids = resource.rcategories.pluck(:category_id).join(', ')
    f.inputs I18n.t(:retailer_details, scope: %w[activerecord labels retailer]) do
      %i[email is_active is_opened].each do |t|
        f.input t
      end
      f.input :password
      f.input :password_confirmation
      f.input :is_show_brand
      f.input :is_show_recipe
      f.input :retailer_type, as: :select, collection: RetailerType.all
      f.input :date_time_offset, label: 'TimeZone', as: :select, collection: Retailer.time_zones.keys
      f.input :show_pending_order_hours, hint: 'number of hours ahead orders sent to the retailer app, should be greater than 1'
      f.input :retailer_group_id, as: :select, collection: RetailerGroup.all
      f.input :with_stock_level
      f.input :is_featured
      f.input :seo_data
      f.input :send_tax_invoice
    end
    f.inputs 'Order Reports' do
      %i[is_generate_report is_report_add_email is_report_add_phone].each do |t|
        f.input t
      end
      f.input :report_parent_id, hint: 'parent retailer id for cumulative orders export/report'
      f.input :report_emails, hint: 'email@domain.com, email@domain.com'
    end
    f.inputs I18n.t(:store_details, scope: %w[activerecord labels retailer]) do
      %i[company_name company_name_ar slug company_address company_address_ar location contact_email commission_value
       phone_number latitude longitude photo].each do |t|
        f.input t
      end
      f.input :photo1, label: 'Background Image En'
      f.inputs 'Background Image Ar', for: [:image, f.object.image || Image.new(priority: 0)] do |img|
        img.input :id, as: :boolean, label: 'Photo file size must be under 2mbs', input_html: { disabled: true }
        img.input :photo, as: :file
      end
    end
    # f.inputs 'Schedule Order' do
    #   f.input :delivery_type_id, as: :select, collection: Retailer.delivery_types
    # end
    f.inputs 'Delivery Detail', for: [:delivery_service, f.object.delivery_service || RetailerHasService.new(retailer_service_id: 1)] do |cf|
      cf.input :is_active
      cf.input :service_fee
      # cf.input :cutoff_time, :as => :string, input_html: {value: cf.object.order_cutoff_time.try(:strip)}, hint: 'after 20:00 no order for tomorrow delivery slots order will be on day after tomorrow delivery slots'
      cf.input :schedule_order_reminder_time, as: :string, input_html: { value: cf.object.schedule_order_reminder_hours.try(:strip) }, hint: 'Reminder to retailer before 1:00 hours'
      # cf.input :delivery_slot_skip_time, :as => :string, input_html: {value: cf.object.delivery_slot_skip_hours.try(:strip)}, hint: 'delivery slots after 4:00 hours'
      cf.input :delivery_payment_types, as: :check_boxes,
               collection: controller.available_payments.map { |apt| [I18n.t(apt.name, scope: %w[activerecord labels locations]), apt.id, { checked: f.object.delivery_payment_type_ids.include?(apt.id) }] }
    end
    f.inputs 'Delivery Zones Details' do
      f.input :delivery_zones, as: :delivery_zones_select
      f.input :locations, as: :locations_select
      %i[delivery_range delivery_notes delivery_team_commitment number_of_deliveries_per_hour_commitment].each do |t|
        f.input t
      end
    end
    # f.input :available_payment_types, as: :check_boxes, member_label: Proc.new { |apt| I18n.t(apt.name, scope: 'activerecord.labels.locations') }
    # f.input :delivery_slot_skip_hours, :as => :string, input_html: {value: f.object.delivery_slot_skip_time.try(:strip)}, hint: 'delivery slots after 4:00 hours'
    # f.input :cutoff_time, :as => :string, input_html: {value: f.object.order_cutoff_time.try(:strip)}, hint: 'after 20:00 no order for tomorrow delivery slots order will be on day after tomorrow delivery slots'
    # f.input :schedule_order_reminder_hours, :as => :string, input_html: {value: f.object.schedule_order_reminder_time.try(:strip)}, hint: 'Reminder to retailer before 1:00 hours'

    f.inputs 'Click and Collect Detail', for: [:click_and_collect_service, f.object.click_and_collect_service || RetailerHasService.new(retailer_service_id: 2)] do |cf|
      cf.input :is_active
      cf.input :service_fee
      cf.input :min_basket_value
      cf.input :delivery_type, as: :select
      cf.input :cutoff_time, as: :string, input_html: { value: cf.object.order_cutoff_time.try(:strip) }, hint: 'after 20:00 no order for tomorrow delivery slots order will be on day after tomorrow delivery slots'
      cf.input :schedule_order_reminder_time, as: :string, input_html: { value: cf.object.schedule_order_reminder_hours.try(:strip) }, hint: 'Reminder to retailer before 1:00 hours'
      cf.input :delivery_slot_skip_time, as: :string, input_html: { value: cf.object.delivery_slot_skip_hours.try(:strip) }, hint: 'delivery slots after 4:00 hours'
      cf.input :click_and_collect_payment_types, as: :check_boxes,
               collection: controller.available_payments.map { |apt| [I18n.t(apt.name, scope: %w[activerecord labels locations]), apt.id, { checked: f.object.click_and_collect_payment_type_ids.include?(apt.id) }] }
    end

    f.inputs 'Banners' do
      f.input :banners
    end
    %w[owner manager].each do |title|
      f.inputs I18n.t("#{title}_details", scope: %w[activerecord labels retailer]) do
        %W[store_#{title}_name store_#{title}_phone_number store_#{title}_email].each do |t|
          f.input t
        end
      end
    end
    f.inputs I18n.t(:integration_level, scope: %w[activerecord labels retailer]) do
      f.input :integration_level
    end
    f.inputs I18n.t(:additional_notes, scope: %w[activerecord labels retailer]) do
      f.input :notes
    end
    f.inputs 'Categories' do
      f.input :ret_category_ids, label: 'Categories', as: :text, hint: 'Enter comma separated Category Ids e.g. 90,80,67'
    end
    # f.has_many :retailer_has_services, heading: "Retailer Has Services", new_record: "Add New", name: false, allow_destroy: true do |cf|
    #   cf.input :retailer_service
    #   cf.input :cutoff_time, :as => :string, input_html: {value: cf.object.service_cutoff_time.try(:strip)}
    #   cf.input :is_active
    # end

    f.actions
  end

  controller do
    def create
      delivery_service = params[:retailer][:delivery_service_attributes]
      click_and_collect_service = params[:retailer][:click_and_collect_service_attributes]

      params[:retailer][:click_and_collect_payment_type_ids] = click_and_collect_service[:click_and_collect_payment_types]
      params[:retailer][:delivery_payment_type_ids] = delivery_service[:delivery_payment_types]
      params[:retailer][:service_fee] = delivery_service[:service_fee]
      # params[:retailer][:delivery_slot_skip_hours] = delivery_service[:delivery_slot_skip_time]
      # params[:retailer][:cutoff_time] = delivery_service[:cutoff_time]
      params[:retailer][:schedule_order_reminder_hours] = delivery_service[:schedule_order_reminder_time]

      locations = params[:retailer][:location_ids].reject(&:blank?) if params[:retailer][:location_ids]
      params[:retailer] = params[:retailer].except(:location_ids) unless locations.blank?
      categories = params[:retailer][:ret_category_ids].scan(/\d+/)
      params[:retailer] = params[:retailer].except(:ret_category_ids, :rcategories) unless categories.blank?
      super

      retailer_delivery_service = RetailerHasService.new(retailer_id: @retailer.id, retailer_service_id: 1)
      retailer_delivery_service.is_active = delivery_service[:is_active]
      retailer_delivery_service.service_fee = delivery_service[:service_fee]
      retailer_delivery_service.cutoff_time = delivery_service[:cutoff_time]
      retailer_delivery_service.schedule_order_reminder_time = delivery_service[:schedule_order_reminder_time]
      retailer_delivery_service.delivery_slot_skip_time = delivery_service[:delivery_slot_skip_time]
      retailer_delivery_service.save

      retailer_cc_service = RetailerHasService.new(retailer_id: @retailer.id, retailer_service_id: 2)
      retailer_cc_service.is_active = click_and_collect_service[:is_active]
      retailer_cc_service.service_fee = click_and_collect_service[:service_fee]
      retailer_cc_service.min_basket_value = click_and_collect_service[:min_basket_value]
      retailer_cc_service.cutoff_time = click_and_collect_service[:cutoff_time]
      retailer_cc_service.schedule_order_reminder_time = click_and_collect_service[:schedule_order_reminder_time]
      retailer_cc_service.delivery_slot_skip_time = click_and_collect_service[:delivery_slot_skip_time]
      retailer_cc_service.delivery_type = click_and_collect_service[:delivery_type]
      retailer_cc_service.save

      unless locations.blank?
        locations.each do |id|
          RetailerHasLocation.create(location_id: id, retailer_id: @retailer.id)
        end
      end
      unless categories.blank?
        values = categories.map { |u| "(#{@retailer.id},#{u})" }.join(',')
        ActiveRecord::Base.connection.execute("INSERT INTO retailer_categories (retailer_id, category_id) VALUES #{values}")
      end
    end

    def update
      if params[:retailer][:password].blank? && params[:retailer][:password_confirmation].blank?
        params[:retailer].delete('password')
        params[:retailer].delete('password_confirmation')
      end
      delivery_service = params[:retailer][:delivery_service_attributes]
      click_and_collect_service = params[:retailer][:click_and_collect_service_attributes]
      retailer_delivery_service = if delivery_service[:id]
                                    RetailerHasService.find_by(id: delivery_service[:id])
                                  else
                                    RetailerHasService.new(retailer_id: params[:id], retailer_service_id: 1)
                                  end
      retailer_delivery_service.is_active = delivery_service[:is_active]
      retailer_delivery_service.service_fee = delivery_service[:service_fee]
      # retailer_delivery_service.delivery_slot_skip_time = delivery_service[:delivery_slot_skip_time]
      # retailer_delivery_service.cutoff_time = delivery_service[:cutoff_time]
      retailer_delivery_service.schedule_order_reminder_time = delivery_service[:schedule_order_reminder_time]
      retailer_delivery_service.save

      retailer_cc_service = if click_and_collect_service[:id]
                              RetailerHasService.find_by(id: click_and_collect_service[:id])
                            else
                              RetailerHasService.new(retailer_id: params[:id], retailer_service_id: 2)
                            end
      retailer_cc_service.is_active = click_and_collect_service[:is_active]
      retailer_cc_service.service_fee = click_and_collect_service[:service_fee]
      retailer_cc_service.min_basket_value = click_and_collect_service[:min_basket_value]
      retailer_cc_service.cutoff_time = click_and_collect_service[:cutoff_time]
      retailer_cc_service.schedule_order_reminder_time = click_and_collect_service[:schedule_order_reminder_time]
      retailer_cc_service.delivery_slot_skip_time = click_and_collect_service[:delivery_slot_skip_time]
      retailer_cc_service.delivery_type = click_and_collect_service[:delivery_type]
      retailer_cc_service.save

      params[:retailer][:click_and_collect_payment_type_ids] = click_and_collect_service[:click_and_collect_payment_types]
      params[:retailer][:delivery_payment_type_ids] = delivery_service[:delivery_payment_types]
      params[:retailer][:service_fee] = delivery_service[:service_fee]
      params[:retailer][:delivery_slot_skip_hours] = delivery_service[:delivery_slot_skip_time]
      params[:retailer][:cutoff_time] = delivery_service[:cutoff_time]
      params[:retailer][:schedule_order_reminder_hours] = delivery_service[:schedule_order_reminder_time]

      RetailerHasLocation.where(retailer_id: params[:id]).delete_all
      locations = params[:retailer][:location_ids]
      if locations and !locations.reject(&:blank?).blank?
        params[:retailer] = params[:retailer].except(:location_ids)
        locations.each do |id|
          RetailerHasLocation.create(location_id: id, retailer_id: params[:id])
        end
      end
      RetailerCategory.where(retailer_id: params[:id]).delete_all
      categories = params[:retailer][:ret_category_ids].scan(/\d+/)
      unless categories.blank?
        params[:retailer] = params[:retailer].except(:ret_category_ids, :rcategories)
        values = categories.map { |u| "(#{params[:id]},#{u})" }.join(',')
        ActiveRecord::Base.connection.execute("INSERT INTO retailer_categories (retailer_id, category_id) VALUES #{values}")
      end
      super
    end

    def destroy
      retailer = Retailer.find(params[:id])
      retailer.update_attributes(is_active: false, is_opened: false)
      redirect_to admin_retailers_path, notice: 'The retailer is not active now!'
    end

    def available_payments
      @available_payments ||= AvailablePaymentType.order(:name).all
    end
  end
end
