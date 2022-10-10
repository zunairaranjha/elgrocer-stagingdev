# frozen_string_literal: true

ActiveAdmin.register RetailerHasLocation do
  menu parent: "Retailers"
  permit_params :location_id, :retailer_id, :min_basket_value

  index do
    column :retailer_id
    column :location_id
    # column(I18n.t('company_name', scope: 'activerecord.labels.retailer')) { |c| c.retailer.company_name rescue '' }
    # column(I18n.t('company_name', scope: 'activerecord.labels.retailer')) { |c| c.retailer.company_name rescue '' }
    # column(I18n.t('name', scope: 'activerecord.labels.locations')) { |c| c.location.name }
    column(I18n.t('min_basket_value', scope: 'activerecord.labels.locations')) { |c| c.min_basket_value }
    actions
  end

  filter :retailer_company_name_cont, as: :string
  filter :location_name_cont, as: :string

  # show do |loc|
  #   panel I18n.t(:delivery_zone, :scope => ["activerecord", "labels", "locations"]) do
  #     attributes_table_for loc do
  #       row :location_name do
  #         loc.location.name
  #       end
  #       row :retailer_name do
  #         loc.retailer.company_name
  #       end
  #       row :min_basket_value
  #     end
  #   end
  # end

  # form html: { enctype: 'multipart/form-data' } do |f|
  #   f.inputs 'Basic details' do
  #     f.input :retailer
  #     f.input :location
  #     f.input :min_basket_value, default: 0
  #   end
  #   f.actions
  # end

  controller do
    def new
      retailer = Retailer.find_by(id: params[:retailer_id])
      location = Location.find_by(id: params[:location_id])
      super do |format|
        @retailer_has_location.retailer = retailer
        @retailer_has_location.location = location
      end
    end

    def parameters
      params[:retailer_has_location]
    end

    def get_retailer_has_location(location_id, retailer_id)
      RetailerHasLocation.find_by(location_id: location_id, retailer_id: retailer_id)
    end

    def check_if_a_model_exists
      location_id = parameters[:location_id]
      retailer_id = parameters[:retailer_id]
      rhl = get_retailer_has_location(location_id, retailer_id)
      if rhl
        redirect_to admin_retailer_has_locations_path(q: {retailer_id_eq: retailer_id}), notice: "The retailer already has this location!"
      end
      rhl.present?
    end

    def create_model
      RetailerHasLocation.create!({
        retailer_id: parameters[:retailer_id],
        location_id: parameters[:location_id],
        min_basket_value: parameters[:min_basket_value]
      })
      redirect_to admin_retailer_has_locations_path(q: {retailer_id_eq: parameters[:retailer_id]})
    end

    def udpate_model
      retailer = RetailerHasLocation.find(params[:id])
      retailer.update!({
        retailer_id: parameters[:retailer_id],
        location_id: parameters[:location_id],
        min_basket_value: parameters[:min_basket_value]
      })
    end

    def update
      udpate_model
      redirect_to admin_retailer_has_locations_path(q: {retailer_id_eq: parameters[:retailer_id]})
    end

    def create
      create_model unless check_if_a_model_exists
    end
  end
end
