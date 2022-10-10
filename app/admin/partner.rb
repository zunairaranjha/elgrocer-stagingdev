ActiveAdmin.register Partner do
  menu parent: "Settings"
  actions :all, except: [:new]
  form do |f|
    f.inputs do 
      names = resource.config.keys
      Partner.create_method(names)
      names.each do |name|
        f.input name.to_sym
      end
    end
    f.actions
  end

  index do
    column :name
    column :created_at
    column :updated_at
    actions
  end

  filter :name

  show do |obj|
    attributes_table :name do 
      obj.config.keys.each do |action|
        row action do
          obj.config[action]
        end
      end
      row :created_at
      row :updated_at
    end
  end

  controller do
    def update
      partner = Partner.find_by_id(resource.id)
      partner.config = params[:partner]
      partner.save
      redirect_to admin_partner_path
    end
  end
end