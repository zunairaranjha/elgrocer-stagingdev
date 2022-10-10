# frozen_string_literal: true

ActiveAdmin.register PartnerConfiguration do
  menu false
  permit_params :key, :fields
  form do |f|
    f.inputs do
      f.input :key
      f.input :partner_fields, hint: 'Please Provide Comma Separated fields e.g field1,field2,field3'
    end
    f.actions
  end

  controller do
    def create 
      partner_conf = PartnerConfiguration.new
      partner_conf.key = params[:partner_configuration][:key]
      partner_conf.fields = params[:partner_configuration][:partner_fields].strip
      partner_conf.save
      create_partner(partner_conf)
      redirect_to admin_partner_configurations_path
    end

    def update
      partner_conf = PartnerConfiguration.find_by(id: resource.id)
      partner_conf.key = params[:partner_configuration][:key]
      if partner_conf.fields.present?
        partner_conf.fields = partner_conf.fields + ",#{params[:partner_configuration][:partner_fields].strip}"
      else
        partner_conf.fields = params[:partner_configuration][:partner_fields].strip
      end

      partner_conf.save
      update_partner(partner_conf, params[:partner_configuration][:partner_fields].strip)
      redirect_to admin_partner_configurations_path
    end

    def create_partner(partner_conf)
      partner = Partner.new
      partner.name = partner_conf.key
      partner.partner_configuration_id = partner_conf.id
      # Hash[a.map {|x| [x, 1]}]
      partner_conf.fields.split(',').each { |keys| partner.config[keys] = '' }
      partner.save
    end

    def update_partner(partner_conf, fields)
      partner = Partner.find_by_partner_configuration_id(partner_conf.id)
      partner.name = partner_conf.key
      fields.split(',').each { |keys| partner.config[keys] = '' }
      partner.save
    end
  end
end

